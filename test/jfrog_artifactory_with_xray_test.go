package test

import (
	"encoding/json"
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

type Bearer_resp struct {

	// defining struct variables
	Access_Token string
	Expiry       int
	Scope        string
	Token_type   string
}

func GetBearer() string {
	client := resty.New()
	client.SetBasicAuth("admin", "password")
	bearer, _ := client.R().
		SetQueryParams(map[string]string{
			"username": "awtest",
			"scope":    "applied-permissions:admin",
		}).
		// SetBody(`{"username":"awtest", "scope":"applied-permissions:admin"}`).
		SetHeader("Content-Type", "application/x-www-form-urlencoded").
		Post("http://jfrog-xray-k15wr-artifactory-1775471376.eu-west-2.elb.amazonaws.com/artifactory/api/security/token")
	// fmt.Println(bearer)
	var resp1 Bearer_resp

	err := json.Unmarshal(bearer.Body(), &resp1)

	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("My token is: %s\n", resp1.Access_Token)
	return resp1.Access_Token
}

func TestXray(t *testing.T) {
	// Apply infrastructure terraform, check for idempotency, and defer a destroy
	infrastructureTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/jfrog-artifactory-with-xray",
	})
	// defer terraform.Destroy(t, infrastructureTerraformOptions)
	terraform.InitAndApplyAndIdempotent(t, infrastructureTerraformOptions)
	artifactoryUrl := terraform.Output(t, infrastructureTerraformOptions, "artifactory_url")

	bearer_token := GetBearer()
	fmt.Printf("BEARER_TOKEN = %s", bearer_token)
	// Apply configuration terraform, check for idempotency, and defer a destroy
	configurationTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/configuration",
		Vars: map[string]interface{}{
			"artifactory_url": artifactoryUrl,
		},
	})
	// defer terraform.Destroy(t, configurationTerraformOptions)
	terraform.InitAndApplyAndIdempotent(t, configurationTerraformOptions)

	// Run subtests
	t.Run("Artifactory Ping", func(t *testing.T) {
		http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/artifactory/api/system/ping", artifactoryUrl), nil, 200, "OK", 3, 5*time.Second)
	})

	t.Run("Xray Ping", func(t *testing.T) {
		http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/xray/api/v1/system/ping", artifactoryUrl), nil, 200, "{\"status\":\"pong\"}", 3, 5*time.Second)
	})

	t.Run("Xray Indexing", func(t *testing.T) {
		client := resty.New()
		// TODO: Supress warnings, use HTTPS?
		// client.SetBasicAuth("admin", bearer_token)
		// client.SetAuthToken("eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJIcXpYRGllN0JCdWZvQ08yS0pKZmxIcG1TbzBuUGdHU0xBYUNDcnJTRDBVIn0.eyJzdWIiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJzY3AiOiJtZW1iZXItb2YtZ3JvdXBzOmFkbWlucyIsImF1ZCI6ImpmcnRAMDFmcGEwNmdlZWtncXcxOTh3anNxYzB5MnAiLCJpc3MiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJleHAiOjE2MzkxNDk4NjcsImlhdCI6MTYzOTE0NjI2NywianRpIjoiYTQxYjVkZGItYzZkZC00MjJhLWJiNWEtNWIxYjViZDgyZTA0In0.kU31VlSdiuglCv6PdsxU5epGkLJAJSBBRLuMOK7jZ6JsoSAe0JqOJ-yV8dKoZTgTSSjR1iM8tHU_MGvECiO7WjU55URAMnJ8130xFuIYggCehv57B-uViUFqlWCsy5c4wymxu7og6CP3XsxZapiO2VsZgdOzbnNySM0RK8_b81s2Q0focnZQprvXL0E8ZbEhiURCQ85GyLNCPnP_KqpeLr4pNSxW01qCeXC9R7EFg9SrHyyNrPJZiynWQqt1Fl03XOkCCPqglGNyCEmo5UucYKfEHvcmMPwXiwRByu3L8FtVyiOZ9LKemxMWJZzhINAVDj1q5cHPTrg9NIv2eBPA_A")

		// Upload a test artefact to Artifactory
		upload_resp, _ := client.R().
			// SetAuthToken("eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJIcXpYRGllN0JCdWZvQ08yS0pKZmxIcG1TbzBuUGdHU0xBYUNDcnJTRDBVIn0.eyJzdWIiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJzY3AiOiJtZW1iZXItb2YtZ3JvdXBzOmFkbWlucyIsImF1ZCI6ImpmcnRAMDFmcGEwNmdlZWtncXcxOTh3anNxYzB5MnAiLCJpc3MiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJleHAiOjE2MzkxNDk4NjcsImlhdCI6MTYzOTE0NjI2NywianRpIjoiYTQxYjVkZGItYzZkZC00MjJhLWJiNWEtNWIxYjViZDgyZTA0In0.kU31VlSdiuglCv6PdsxU5epGkLJAJSBBRLuMOK7jZ6JsoSAe0JqOJ-yV8dKoZTgTSSjR1iM8tHU_MGvECiO7WjU55URAMnJ8130xFuIYggCehv57B-uViUFqlWCsy5c4wymxu7og6CP3XsxZapiO2VsZgdOzbnNySM0RK8_b81s2Q0focnZQprvXL0E8ZbEhiURCQ85GyLNCPnP_KqpeLr4pNSxW01qCeXC9R7EFg9SrHyyNrPJZiynWQqt1Fl03XOkCCPqglGNyCEmo5UucYKfEHvcmMPwXiwRByu3L8FtVyiOZ9LKemxMWJZzhINAVDj1q5cHPTrg9NIv2eBPA_A").
			// SetHeader("Authorization", "Bearer eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJIcXpYRGllN0JCdWZvQ08yS0pKZmxIcG1TbzBuUGdHU0xBYUNDcnJTRDBVIn0.eyJzdWIiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJzY3AiOiJtZW1iZXItb2YtZ3JvdXBzOmFkbWlucyIsImF1ZCI6ImpmcnRAMDFmcGEwNmdlZWtncXcxOTh3anNxYzB5MnAiLCJpc3MiOiJqZnJ0QDAxZnBhMDZnZWVrZ3F3MTk4d2pzcWMweTJwXC91c2Vyc1wvYWRtaW4iLCJleHAiOjE2MzkxNDk4NjcsImlhdCI6MTYzOTE0NjI2NywianRpIjoiYTQxYjVkZGItYzZkZC00MjJhLWJiNWEtNWIxYjViZDgyZTA0In0.kU31VlSdiuglCv6PdsxU5epGkLJAJSBBRLuMOK7jZ6JsoSAe0JqOJ-yV8dKoZTgTSSjR1iM8tHU_MGvECiO7WjU55URAMnJ8130xFuIYggCehv57B-uViUFqlWCsy5c4wymxu7og6CP3XsxZapiO2VsZgdOzbnNySM0RK8_b81s2Q0focnZQprvXL0E8ZbEhiURCQ85GyLNCPnP_KqpeLr4pNSxW01qCeXC9R7EFg9SrHyyNrPJZiynWQqt1Fl03XOkCCPqglGNyCEmo5UucYKfEHvcmMPwXiwRByu3L8FtVyiOZ9LKemxMWJZzhINAVDj1q5cHPTrg9NIv2eBPA_A").
			SetHeader("Authorization", fmt.Sprintf("Bearer %s", bearer_token)).
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
