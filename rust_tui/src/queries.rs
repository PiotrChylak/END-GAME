pub const PLAYER_STATE_QUERY: &str = r#"query {
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

pub const NODE_META_QUERY: &str = r#"query {
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

pub const CHOICE_QUERY: &str = r#"query {
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

pub const GAMBLING_CONFIG_QUERY: &str = r#"query {
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
}"#;
