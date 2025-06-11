use std::{io, time::{Duration, Instant}};

use crossterm::{
    event::{self, Event as CEvent, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    widgets::{Block, Borders, Paragraph},
    Terminal,
};
use serde::{Deserialize, Serialize};
use num_bigint::BigUint;
use hex;

// --- Start: Your actual Dojo model definitions ---

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerState {
    pub player: String,
    pub balance: String,
    pub current_node: u16,
    pub story_completed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerDecision {
    pub player: String,
    pub node_id: u16,
    pub choice: u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeMeta {
    pub id: u16,
    pub text: String,
    pub gambling_node: bool,
    pub is_ending: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Choice {
    pub node_id: u16,
    pub choice_id: u8,
    pub text: String,
    pub next_node: u16,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GamblingLevelConfig {
    pub player: String,
    pub token: String,
    pub level: u8,
    pub multiplier: String,
    pub chances: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Edge<T> {
    pub node: T,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Connection<T> {
    pub edges: Option<Vec<Edge<T>>>,
    #[serde(rename = "totalCount")]
    pub total_count: Option<u32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToriiResponse {
    pub data: Option<ModelsData>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelsData {
    #[serde(rename = "stwoTheEndPlayerStateModels")]
    pub player_states: Option<Connection<PlayerState>>,
    #[serde(rename = "stwoTheEndNodeMetaModels")]
    pub node_metas: Option<Connection<NodeMeta>>,
    #[serde(rename = "stwoTheEndChoiceModels")]
    pub choices: Option<Connection<Choice>>,
    #[serde(rename = "stwoTheEndGamblingLevelConfigModels")]
    pub gambling_level_configs: Option<Connection<GamblingLevelConfig>>,
}


#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut last_tick = Instant::now();
    let tick_rate = Duration::from_millis(1000); // Update every 1 second

    let mut models_display = String::new();
    let mut current_player_node: Option<u16> = None;

    loop {
        terminal.draw(|f| {
            let size = f.size();
            let block = Block::default().borders(Borders::ALL).title("StwoTheEnd - Terminal User Interface");
            let paragraph = Paragraph::new(models_display.clone()).block(block);
            f.render_widget(paragraph, size);
        })?;

        let timeout = tick_rate
            .checked_sub(last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)? {
            if let CEvent::Key(key) = event::read()? {
                if let KeyCode::Char('q') = key.code {
                    break;
                }
            }
        }

        if last_tick.elapsed() >= tick_rate {
            // Fetch data from Torii
            let torii_url = "http://localhost:8080/graphql";

            let player_state_query = r#"query {
                stwoTheEndPlayerStateModels {
                    edges {
                        node {
                            player
                            balance
                            current_node
                            story_completed
                        }
                    }
                    totalCount
                }
            }"#;

            let node_meta_query = r#"query {
                stwoTheEndNodeMetaModels (last: 1000){
                    edges {
                        node {
                            id
                            text
                            gambling_node
                            is_ending
                        }
                    }
                    totalCount
                }
            }"#;

            let choice_query = r#"query {
                stwoTheEndChoiceModels (last: 1000){
                    edges {
                        node {
                            node_id
                            choice_id
                            text
                            next_node
                        }
                    }
                    totalCount
                }
            }"#;

            let gambling_config_query = r#"query {
                stwoTheEndGamblingLevelConfigModels {
                    edges {
                        node {
                            player
                            token
                            level
                            multiplier
                            chances
                        }
                    }
                }
            }"#; // Removed totalCount from query because it's missing in actual response

            let client = reqwest::Client::new();
            models_display.clear();

            // Fetch Player States
            match client
                .post(torii_url)
                .json(&serde_json::json!({ "query": player_state_query }))
                .send()
                .await
            {
                Ok(response) => {
                    if response.status().is_success() {
                        match response.json::<ToriiResponse>().await {
                            Ok(json_response) => {
                                if let Some(data) = json_response.data {
                                    models_display.push_str("--- Player State ---\n");
                                    if let Some(player_states_conn) = data.player_states {
                                        if let Some(edges) = player_states_conn.edges {
                                            if edges.is_empty() {
                                                models_display.push_str("No player states found.\n");
                                            } else {
                                                // Only consider the first player state for current_node
                                                if let Some(first_ps_edge) = edges.first() {
                                                    let ps = &first_ps_edge.node;
                                                    current_player_node = Some(ps.current_node);

                                                    let hex_balance_str = &ps.balance[2..];
                                                    let padded_hex_balance_str = if hex_balance_str.len() % 2 != 0 {
                                                        format!("0{}", hex_balance_str)
                                                    } else {
                                                        hex_balance_str.to_string()
                                                    };

                                                    let decoded_bytes = hex::decode(&padded_hex_balance_str)?;
                                                    let balance_biguint = BigUint::from_bytes_be(&decoded_bytes);
                                                    
                                                    // // Divide by 10^18
                                                    // let divisor = BigUint::from(10u64).pow(18);
                                                    // let formatted_balance = if divisor > BigUint::from(0u64) {
                                                    //     (balance_biguint / divisor).to_string()
                                                    // } else {
                                                    //     balance_biguint.to_string()
                                                    // };

                                                    models_display.push_str(&format!(
                                                        "Player address: {} \nBalance: {}\nCurrent Node: {}\nStory Completed: {}\n",
                                                        ps.player,
                                                        balance_biguint.to_string(),
                                                        ps.current_node,
                                                        ps.story_completed
                                                    ));
                                                }
                                            }
                                        } else {
                                            models_display.push_str("No player states found.\n");
                                        }
                                    } else {
                                        models_display.push_str("No player states found.\n");
                                    }
                                } else {
                                    models_display.push_str("No data in Torii response for Player States.\n");
                                }
                            },
                            Err(e) => {
                                models_display.push_str(&format!("Failed to parse Player States JSON response: {}\n", e));
                            }
                        }
                    } else {
                        models_display.push_str(&format!("Error fetching Player States: HTTP Status {}\n", response.status()));
                    }
                }
                Err(e) => {
                    models_display.push_str(&format!("Failed to send request for Player States: {}\n", e));
                }
            }

            // Fetch Node Metas
            let mut has_gambling_node = false;
            models_display.push_str("\n--- Current Node Meta ---\n");
            if let Some(node_id) = current_player_node {
                match client
                    .post(torii_url)
                    .json(&serde_json::json!({ "query": node_meta_query }))
                    .send()
                    .await
                {
                    Ok(response) => {
                        if response.status().is_success() {
                            match response.json::<ToriiResponse>().await {
                                Ok(json_response) => {
                                    if let Some(data) = json_response.data {
                                        if let Some(node_metas_conn) = data.node_metas {
                                            if let Some(edges) = node_metas_conn.edges {
                                                let filtered_node_meta = edges.into_iter().find(|nm_edge| nm_edge.node.id == node_id);
                                                if let Some(node_meta_edge) = filtered_node_meta {
                                                    let nm = node_meta_edge.node;
                                                    if nm.gambling_node {
                                                        has_gambling_node = true;
                                                    }
                                                    let decoded_text = hex::decode(&nm.text[2..])
                                                        .unwrap_or_default();
                                                    let readable_text = String::from_utf8(decoded_text)
                                                        .unwrap_or_else(|_| "<invalid UTF-8>".to_string());

                                                    models_display.push_str(&format!(
                                                        "ID: {}\nText: '{}'\nGambling Node: {}\nIs Ending: {}\n",
                                                        nm.id,
                                                        readable_text,
                                                        nm.gambling_node,
                                                        nm.is_ending
                                                    ));
                                                } else {
                                                    models_display.push_str(&format!("Node Meta for ID {} not found.\n", node_id));
                                                }
                                            } else {
                                                models_display.push_str("No node metas found.\n");
                                            }
                                        } else {
                                            models_display.push_str("No node metas found.\n");
                                        }
                                    } else {
                                        models_display.push_str("No data in Torii response for Node Metas.\n");
                                    }
                                },
                                Err(e) => {
                                    models_display.push_str(&format!("Failed to parse Node Metas JSON response: {}\n", e));
                                }
                            }
                        } else {
                            models_display.push_str(&format!("Error fetching Node Metas: HTTP Status {}\n", response.status()));
                            models_display.push_str(&format!("Please make sure you have player at this address and a node with ID: {}\n", node_id));
                        }
                    }
                    Err(e) => {
                        models_display.push_str(&format!("Failed to send request for Node Metas: {}\n", e));
                    }
                }
            } else {
                models_display.push_str("Current player node not determined yet or no player state found.\n");
            }

            // Fetch Gambling Level Configs (conditionally)
            if has_gambling_node {
                match client
                    .post(torii_url)
                    .json(&serde_json::json!({ "query": gambling_config_query }))
                    .send()
                    .await
                {
                    Ok(response) => {
                        if response.status().is_success() {
                            match response.json::<ToriiResponse>().await {
                                Ok(json_response) => {
                                    if let Some(data) = json_response.data {
                                        models_display.push_str("\n--- Gambling Level Configs ---\n");
                                        if let Some(gambling_configs_conn) = data.gambling_level_configs {
                                            if let Some(edges) = gambling_configs_conn.edges {
                                                if edges.is_empty() {
                                                    models_display.push_str("No gambling level configs found.\n");
                                                } else {
                                                    for edge in edges {
                                                        let glc = edge.node;

                                                        // Display multiplier directly as it might be an enum variant name or a string
                                                        models_display.push_str(&format!(
                                                            "Player address: {} \nToken address: {} \nLevel: {} \nMultiplier: {} \nChances: {}\n",
                                                            glc.player,
                                                            glc.token,
                                                            glc.level,
                                                            glc.multiplier, // Display multiplier directly
                                                            glc.chances
                                                        ));
                                                    }
                                                }
                                            } else {
                                                models_display.push_str("No gambling level configs found.\n");
                                            }
                                        } else {
                                            models_display.push_str("No gambling level configs found.\n");
                                        }
                                    } else {
                                        models_display.push_str("No data in Torii response for Gambling Level Configs.\n");
                                    }
                                },
                                Err(e) => {
                                    models_display.push_str(&format!("Failed to parse Gambling Level Configs JSON response: {}\n", e));
                                }
                            }
                        } else {
                            models_display.push_str(&format!("Error fetching Gambling Level Configs: HTTP Status {}\n", response.status()));
                        }
                    }
                    Err(e) => {
                        models_display.push_str(&format!("Failed to send request for Gambling Level Configs: {}\n", e));
                    }
                }
            }

            // Fetch Choices
            models_display.push_str(&format!("\n--- Current Node Choices (ID: {})---\n", current_player_node.unwrap_or(0)));
            if let Some(node_id) = current_player_node {
                match client
                    .post(torii_url)
                    .json(&serde_json::json!({ "query": choice_query }))
                    .send()
                    .await
                {
                    Ok(response) => {
                        if response.status().is_success() {
                            match response.json::<ToriiResponse>().await {
                                Ok(json_response) => {
                                    if let Some(data) = json_response.data {
                                        if let Some(choices_conn) = data.choices {
                                            if let Some(edges) = choices_conn.edges {
                                                let filtered_choices: Vec<Choice> = edges.into_iter()
                                                    .filter(|c_edge| c_edge.node.node_id == node_id)
                                                    .map(|c_edge| c_edge.node)
                                                    .collect();
                                                if filtered_choices.is_empty() {
                                                    models_display.push_str(&format!("No choices found for current node (ID: {}).\n", node_id));
                                                } else {
                                                    for c in filtered_choices {
                                                        let decoded_text = hex::decode(&c.text[2..])
                                                            .unwrap_or_default();
                                                        let readable_text = String::from_utf8(decoded_text)
                                                            .unwrap_or_else(|_| "<invalid UTF-8>".to_string());
                                                        models_display.push_str(&format!(
                                                            "Choice ID: {}, Text: '{}', Next Node: {}\n",
                                                            c.choice_id,
                                                            readable_text,
                                                            c.next_node
                                                        ));
                                                    }
                                                }
                                            } else {
                                                models_display.push_str("No choices found.\n");
                                            }
                                        } else {
                                            models_display.push_str("No data in Torii response for Choices.\n");
                                        }
                                    }
                                },
                                Err(e) => {
                                    models_display.push_str(&format!("Failed to parse Choices JSON response: {}\n", e));
                                }
                            }
                        } else {
                            models_display.push_str(&format!("Error fetching Choices: HTTP Status {}\n", response.status()));
                            models_display.push_str(&format!("Please make sure you have player at this address and choices with node ID: {}\n", node_id));
                        }
                    }
                    Err(e) => {
                        models_display.push_str(&format!("Failed to send request for Choices: {}\n", e));
                    }
                }
            } else {
                models_display.push_str("Current player node not determined yet or no player state found.\n");
            }

            last_tick = Instant::now();
        }
    }

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    Ok(())
} 