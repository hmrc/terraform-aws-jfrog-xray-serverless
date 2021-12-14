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

	repoName := (fmt.Sprintf("test-local-generic-repo-%s", time.Now().Format("20060102150405")))

	// Additional test prep
	client.R().
		SetHeader("Accept", "*/*").
		SetHeader("Content-Type", "application/json").
		SetBody(map[string]interface{}{"rclass": "local", "packageType": "generic", "xrayIndex": true}).
		Put(fmt.Sprintf("%s/artifactory/api/repositories/%s", artifactoryUrl, repoName))

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
			Put(fmt.Sprintf("%s/artifactory/%s/test.jar", artifactoryUrl, repoName))
		assert.Equal(t, 201, upload_resp.StatusCode())

		// Query artefact summary in Xray until the test artefact has been indexed
		artefactName := "notfound"
	Loop:
		for i := 0; i < 20; i++ {
			artefact_summary_resp, _ := client.R().
				SetBody(fmt.Sprintf(`{"paths": ["default/%s/test.jar"]}`, repoName)).
				SetHeader("Content-Type", "application/json").
				SetResult(&XrayArtifactSummaryResponse{}).
				Post(fmt.Sprintf("%s/xray/api/v1/summary/artifact", artifactoryUrl))
			artefact_summary_result := artefact_summary_resp.Result().(*XrayArtifactSummaryResponse)

			if len(artefact_summary_result.Errors) == 0 {
				artefactName = artefact_summary_result.Artifacts[0].General.Name
				break Loop
			}

			time.Sleep(5 * time.Second)
		}
		assert.Equal(t, "test.jar", artefactName)
	})
}
