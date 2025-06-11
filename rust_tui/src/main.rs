mod models;
mod queries;
mod display;
mod fetcher;
mod text_wrapper;

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

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut last_tick = Instant::now();
    let tick_rate = Duration::from_millis(1000);
    let mut models_display = String::new();
    let mut current_player_node: Option<u16> = None;
    let mut is_developer_mode = true;

    let client = reqwest::Client::new();
    let torii_url = "http://localhost:8080/graphql";

    loop {
        terminal.draw(|f| {
            let size = f.size();
            let block = Block::default()
                .borders(Borders::ALL)
                .title("StwoTheEnd - Terminal User Interface");
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
                } else if let KeyCode::Char('t') = key.code {
                    is_developer_mode = !is_developer_mode;
                    if is_developer_mode {
                        models_display.push_str("\n--- Switched to Developer Mode ---\n");
                    } else {
                        models_display.push_str("\n--- Switched to Story Mode ---\n");
                    }
                }
            }
        }

        if last_tick.elapsed() >= tick_rate {
            models_display.clear();

            // Fetch Player States
            if is_developer_mode {
                models_display.push_str("--- Player State ---\n");
            }
            if let Ok(response) = fetcher::fetch_data(&client, torii_url, queries::PLAYER_STATE_QUERY).await {
                if let Some(data) = response.data {
                    if let Some(player_states) = data.player_states {
                        if let Some(edges) = player_states.edges {
                            if let Some(first_ps) = edges.first() {
                                current_player_node = Some(first_ps.node.current_node);
                                if is_developer_mode {
                                    models_display.push_str(&display::format_player_state(&first_ps.node, is_developer_mode));
                                }
                            }
                        }
                    }
                }
            } else if is_developer_mode {
                models_display.push_str("Error fetching Player States.\n");
            }

            // Fetch and display Node Meta
            let mut has_gambling_node = false;
            if is_developer_mode {
                models_display.push_str("\n--- Current Node Meta ---\n");
            }
            if let Some(node_id) = current_player_node {
                if let Ok(response) = fetcher::fetch_data(&client, torii_url, queries::NODE_META_QUERY).await {
                    if let Some(data) = response.data {
                        if let Some(node_metas) = data.node_metas {
                            if let Some(edges) = node_metas.edges {
                                if let Some(node_meta_edge) = edges.iter().find(|nm_edge| nm_edge.node.id == node_id) {
                                    let nm = &node_meta_edge.node;
                                    if nm.gambling_node {
                                        has_gambling_node = true;
                                    }
                                    models_display.push_str(&display::format_node_meta(nm, is_developer_mode));
                                } else if is_developer_mode {
                                    models_display.push_str(&format!("Node Meta for ID {} not found.\n", node_id));
                                }
                            } else if is_developer_mode {
                                models_display.push_str("No node metas found.\n");
                            }
                        } else if is_developer_mode {
                            models_display.push_str("No node metas found.\n");
                        }
                    } else if is_developer_mode {
                        models_display.push_str("No data in Torii response for Node Metas.\n");
                    }
                } else if is_developer_mode {
                    models_display.push_str("Error fetching Node Metas.\n");
                }
            } else if is_developer_mode {
                models_display.push_str("Current player node not determined yet or no player state found.\n");
            }

            // Fetch and display Gambling Level Configs (conditionally)
            if has_gambling_node {
                if is_developer_mode {
                    models_display.push_str("\n--- Gambling Level Configs ---\n");
                }
                if let Ok(response) = fetcher::fetch_data(&client, torii_url, queries::GAMBLING_CONFIG_QUERY).await {
                    if let Some(data) = response.data {
                        if let Some(gambling_configs) = data.gambling_level_configs {
                            if let Some(edges) = gambling_configs.edges {
                                for edge in edges {
                                    models_display.push_str(&display::format_gambling_config(&edge.node));
                                }
                            } else if is_developer_mode {
                                models_display.push_str("No gambling level configs found.\n");
                            }
                        } else if is_developer_mode {
                            models_display.push_str("No gambling level configs found.\n");
                        }
                    } else if is_developer_mode {
                        models_display.push_str("No data in Torii response for Gambling Level Configs.\n");
                    }
                } else if is_developer_mode {
                    models_display.push_str("Error fetching Gambling Level Configs.\n");
                }
            } else if is_developer_mode {
                // Only display this if we explicitly tried to fetch gambling data and it failed
                // and not just because it's not a gambling node.
                // In this case, we remove the message for when it's not a gambling node, because it's not an error.
            }

            // Fetch and display Choices
            if is_developer_mode {
                models_display.push_str(&format!("\n--- Current Node Choices (ID: {})---\n", current_player_node.unwrap_or(0)));
            }
            if let Some(node_id) = current_player_node {
                if let Ok(response) = fetcher::fetch_data(&client, torii_url, queries::CHOICE_QUERY).await {
                    if let Some(data) = response.data {
                        if let Some(choices) = data.choices {
                            if let Some(edges) = choices.edges {
                                let filtered_choices: Vec<_> = edges
                                    .into_iter()
                                    .filter(|c_edge| c_edge.node.node_id == node_id)
                                    .collect();
                                if filtered_choices.is_empty() && is_developer_mode {
                                    models_display.push_str(&format!("No choices found for current node (ID: {}).\n", node_id));
                                } else {
                                    for c_edge in filtered_choices {
                                        models_display.push_str(&display::format_choice(&c_edge.node, is_developer_mode));
                                    }
                                }
                            } else if is_developer_mode {
                                models_display.push_str("No choices found.\n");
                            }
                        } else if is_developer_mode {
                            models_display.push_str("No data in Torii response for Choices.\n");
                        }
                    }
                } else if is_developer_mode {
                    models_display.push_str("Error fetching Choices.\n");
                }
            } else if is_developer_mode {
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