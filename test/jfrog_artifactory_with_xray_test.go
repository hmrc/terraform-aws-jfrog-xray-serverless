package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/go-resty/resty/v2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type XrayArtifactSummaryResponse struct {
	Artifacts []struct {
		General struct {
			Name string `json:"name"`
		} `json:"general"`
	} `json:"artifacts"`
	Errors []struct {
		Error string `json:"error"`
	} `json:"errors"`
}

func TestXray(t *testing.T) {
	// Apply terraform, check for idempotency, and defer a destroy
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/jfrog-artifactory-with-xray",
	})
	// defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApplyAndIdempotent(t, terraformOptions)
	artifactoryUrl := terraform.Output(t, terraformOptions, "artifactory_url")

	// Create HTTP client for interacting with Artifactory/Xray
	client := resty.New()
	client.SetBasicAuth("admin", "password")
	client.SetDisableWarn(true)

	// Additional test prep
	client.R().
		SetHeader("Accept", "*/*").
		SetHeader("Content-Type", "application/json").
		SetBody(map[string]interface{}{"rclass": "local", "packageType": "generic"}).
		Put(fmt.Sprintf("%s/artifactory/api/repositories/test-local-generic-repo", artifactoryUrl))

	// Run subtests
	t.Run("Artifactory Ping", func(t *testing.T) {
		http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/artifactory/api/system/ping", artifactoryUrl), nil, 200, "OK", 3, 5*time.Second)
	})

	t.Run("Xray Ping", func(t *testing.T) {
		http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/xray/api/v1/system/ping", artifactoryUrl), nil, 200, "{\"status\":\"pong\"}", 3, 5*time.Second)
	})

	t.Run("Xray Indexing", func(t *testing.T) {
		// Upload a test artefact to Artifactory
		upload_resp, _ := client.R().
			SetBody(`this is an artefact sucka`).
			Put(fmt.Sprintf("%s/artifactory/test-local-generic-repo/test.jar", artifactoryUrl))
		assert.Equal(t, 201, upload_resp.StatusCode())

		// Query artefact summary in Xray until the test artefact has been indexed
		Loop:
			for i := 0; i < 5; i++ {
				artefact_summary_resp, _ := client.R().
					SetBody(`{"paths": ["default/test-local-generic-repo/test.jar"]}`).
					SetHeader("Content-Type", "application/json").
					SetResult(&XrayArtifactSummaryResponse{}).
					Post(fmt.Sprintf("%s/xray/api/v1/summary/artifact", artifactoryUrl))
				artefact_summary_result := artefact_summary_resp.Result().(*XrayArtifactSummaryResponse)

				if len(artefact_summary_result.Errors) == 0 {
					assert.Equal(t, "test.jar", artefact_summary_result.Artifacts[0].General.Name)
					break Loop
				}

				time.Sleep(2 * time.Second)
			}
	})
}
