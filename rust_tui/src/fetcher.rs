use crate::models::{ToriiResponse};
use reqwest;

pub async fn fetch_data(
    client: &reqwest::Client,
    torii_url: &str,
    query: &str,
) -> Result<ToriiResponse, Box<dyn std::error::Error>> {
    let response = client
        .post(torii_url)
        .json(&serde_json::json!({ "query": query }))
        .send()
        .await?;

    if response.status().is_success() {
        Ok(response.json::<ToriiResponse>().await?)
    } else {
        Err(format!("HTTP Status {}", response.status()).into())
    }
}
