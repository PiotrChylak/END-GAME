use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerState {
    pub player: String,
    pub balance: String,
    pub current_node: u32,
    pub story_completed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlayerDecision {
    pub player: String,
    pub node_id: u32,
    pub choice: u8,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeMeta {
    pub id: u32,
    pub text: String,
    pub gambling_node: bool,
    pub is_ending: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Choice {
    pub node_id: u32,
    pub choice_id: u8,
    pub text: String,
    pub next_node: u32,
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
