pub fn get_story_text(node_id: u16, original_node_text: &str) -> String {
    match node_id {
        1 => "You wake up in a dimly lit room, unsure of how you got there. \n".to_string(),
        2 => "A mysterious figure approaches you, their face obscured by shadows.".to_string(),
        // Add more node_id to story text mappings here
        _ => format!("Original Node Info (ID: {}): '{}'", node_id, original_node_text),
    }
}

pub fn get_choice_text(node_id: u16, choice_id: u8, original_choice_text: &str) -> String {
    match (node_id, choice_id) {
        (1, 1) => "[1] Investigate the strange markings on the wall.".to_string(),
        (1, 2) => "[2] Try to find a way out of the room.".to_string(),
        // Add more (node_id, choice_id) to story text mappings here
        _ => format!("Choice ID: {}, Original Choice Text: '{}'", choice_id, original_choice_text),
    }
} 