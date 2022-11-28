#![deny(unused_crate_dependencies)]

pub mod do_things;

use anyhow::Result;
use ethers::providers::{Http, Provider};
use rand::Rng;
use rocket::serde::{json::serde_json, json::Json, Deserialize, Serialize};
use rocket::tokio::task::spawn;
use rocket::{post, State};
use std::sync::Arc;
use tokio as _;

pub struct WebserverState {
    pub provider: Arc<Provider<Http>>, // you might need to change this for your needs as well
    pub should_be_async: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ChainlinkEARequest {
    pub id: String,
    pub data: do_things::ExampleRequestData, // you'll need to change this to your type
    pub meta: Option<serde_json::Value>,
    pub response_url: Option<String>,
}

fn format_response(
    result: Result<do_things::ChainlinkResponse, anyhow::Error>,
) -> Json<serde_json::Value> {
    match result {
        Ok(data) => Json(serde_json::json!({"data": data})),
        Err(e) => Json(serde_json::json!({"error": e.to_string()})),
    }
}

// TODO prefix all logs with ID from request
#[post("/compute", format = "json", data = "<input_data>")]
pub async fn compute(
    webserver_state: &State<WebserverState>,
    input_data: Json<ChainlinkEARequest>,
) -> Json<serde_json::Value>{
    if webserver_state.should_be_async {
        let new_provider = webserver_state.provider.clone();
        spawn(async move {
            let result = do_things::compute_internal(new_provider, input_data.data.clone()).await;
            // send the result to the chainlink node
            reqwest::Client::new()
                .patch(input_data.into_inner().response_url.unwrap())
                .body(format_response(result).to_string())
                .send()
                .await
                .unwrap();
        });
        Json(serde_json::json!({
            "pending": true
        }))
        // end of thread
    } else {
        let res = format_response(
            do_things::compute_internal(
                webserver_state.provider.clone(), 
                input_data.data.clone()
            )
            .await,
        ); 
        return res; 
    }
}

#[rocket::main]
async fn main() -> Result<()> {
    dotenv::dotenv().ok();
    let api_url = std::env::var("API_URL").expect("API_URL must be set.");
    let should_be_async = std::env::var("SHOULD_BE_ASYNC")
        .map_or_else(|_| false, |n| n.parse::<bool>().unwrap_or(false));

    // create an ethers HTTP provider
    let provider = Arc::new(Provider::<Http>::try_from(api_url)?);

    let _ = rocket::build()
        .manage(WebserverState {
            provider,
            should_be_async,
        })
        .mount("/", rocket::routes![compute])
        .launch()
        .await?;

    Ok(())
}

/// Helper function for testing inputs to Chainlink EA without having to run a node.
pub async fn ea_example_api_call(
    api_url: String
) -> Result<serde_json::Value, anyhow::Error> {

    // Job id when chainlink calls is not random. This is just for testing purposes. 
    let mut rng = rand::thread_rng();
    let random_job_id: u16 = rng.gen();
    let map = serde_json::json!({
        "id": random_job_id.to_string(),
        "data":
        {
             "block_num": 8033444,
        }
    });
    let client = reqwest::Client::new();
    let res = client
        .post(api_url)
        .json(&map)
        .send()
        .await?
        .json::<serde_json::Value>()
        .await?;    
    Ok(res)
}


#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[tokio::test]
    /// This test will just call the API and compare the duration to the block time.
    async fn api_call_test() -> Result<(), anyhow::Error> {
        let response_data =
            ea_example_api_call("http://127.0.0.1:8000/compute".to_string())
                .await?;
        
        let one_second = Duration::new(1, 0);
        let duration = response_data.get("data").unwrap().get("duration").unwrap().get("secs").unwrap().as_u64().unwrap();
        assert_ne!(Duration::new(duration, 0), one_second);
        Ok(())
    }
}