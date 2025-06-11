use crate::models::{PlayerState, NodeMeta, Choice, GamblingLevelConfig};
use crate::text_wrapper;
use num_bigint::BigUint;
use hex;

pub fn format_player_state(ps: &PlayerState, is_developer_mode: bool) -> String {
    if !is_developer_mode {
        return String::new();
    }

    let hex_balance_str = &ps.balance[2..];
    let padded_hex_balance_str = if hex_balance_str.len() % 2 != 0 {
        format!("0{}", hex_balance_str)
    } else {
        hex_balance_str.to_string()
    };

    let decoded_bytes = hex::decode(&padded_hex_balance_str).unwrap_or_default();
    let balance_biguint = BigUint::from_bytes_be(&decoded_bytes);

    format!(
        "Player address: {} \nBalance: {}\nCurrent Node: {}\nStory Completed: {}\n",
        ps.player,
        balance_biguint.to_string(),
        ps.current_node,
        ps.story_completed
    )
}

pub fn format_node_meta(nm: &NodeMeta, is_developer_mode: bool) -> String {
    if is_developer_mode {
        let decoded_text = hex::decode(&nm.text[2..]).unwrap_or_default();
        let readable_text = String::from_utf8(decoded_text)
            .unwrap_or_else(|_| "<invalid UTF-8>".to_string());

        format!(
            "ID: {}\nText: '{}'\nGambling Node: {}\nIs Ending: {}\n",
            nm.id, readable_text, nm.gambling_node, nm.is_ending
        )
    } else {
        let readable_text = hex::decode(&nm.text[2..]).unwrap_or_default();
        let readable_text = String::from_utf8(readable_text)
            .unwrap_or_else(|_| "<invalid UTF-8>".to_string());
        format!("{}\n", text_wrapper::get_story_text(nm.id, &readable_text))
    }
}

pub fn format_choice(c: &Choice, is_developer_mode: bool) -> String {
    if is_developer_mode {
        let decoded_text = hex::decode(&c.text[2..]).unwrap_or_default();
        let readable_text = String::from_utf8(decoded_text)
            .unwrap_or_else(|_| "<invalid UTF-8>".to_string());
        format!(
            "Choice ID: {}, Text: '{}', Next Node: {}\n",
            c.choice_id, readable_text, c.next_node
        )
    } else {
        let decoded_text = hex::decode(&c.text[2..]).unwrap_or_default();
        let readable_text = String::from_utf8(decoded_text)
            .unwrap_or_else(|_| "<invalid UTF-8>".to_string());
        format!("{}\n", text_wrapper::get_choice_text(c.node_id, c.choice_id, &readable_text))
    }
}

pub fn format_gambling_config(glc: &GamblingLevelConfig) -> String {
    format!(
        "Player address: {} \nToken address: {} \nLevel: {} \nMultiplier: {} \nChances: {}\n",
        glc.player, glc.token, glc.level, glc.multiplier, glc.chances
    )
}
