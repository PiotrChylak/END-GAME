use stwo_the_end::models::{NodeMeta, Choice};
use dojo::model::ModelStorage;

pub fn tree_constructor(mut world: dojo::world::WorldStorage) {
    world.write_model(@NodeMeta{ id: 1, text: 'Journey Begins!', gambling_node: false, is_ending: false });
    world.write_model(@Choice { node_id: 1, choice_id: 1, text: 'continue', next_node: 11 });

    world.write_model(@NodeMeta{ id: 11, text: 'Stay/Hangout', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 11, choice_id: 1, text: 'Stay at home', next_node: 111 });
    world.write_model(@Choice { node_id: 11, choice_id: 2, text: 'Go to the park', next_node: 112 });

    world.write_model(@NodeMeta{ id: 111, text: 'Home', gambling_node: false, is_ending: false});
    world.write_model(@Choice{ node_id: 111, choice_id: 1, text: 'Continue', next_node: 5});

    world.write_model(@NodeMeta{ id: 112, text: 'Park', gambling_node: false, is_ending: false});
    world.write_model(@Choice{ node_id: 112, choice_id: 1, text: 'Continue', next_node: 10});

    world.write_model(@NodeMeta{ id: 5, text: 'Match bet', gambling_node: true, is_ending: false});
    world.write_model(@Choice{ node_id: 5, choice_id: 1, text: 'Bet', next_node: 1111});
    world.write_model(@Choice{ node_id: 5, choice_id: 2, text: 'Skip', next_node: 1111});

    world.write_model(@NodeMeta{ id: 10, text: 'Beer drinking contest', gambling_node: true, is_ending: false});
    world.write_model(@Choice{ node_id: 10, choice_id: 1, text: 'Bet', next_node: 1121});
    world.write_model(@Choice{ node_id: 10, choice_id: 2, text: 'Skip', next_node: 1121});

    world.write_model(@NodeMeta{ id: 1111, text: 'Phone-call from old friend', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 1111, choice_id: 1 ,text: 'Ignore him', next_node: 11111});
    world.write_model(@Choice { node_id: 1111, choice_id: 2, text: 'Go check what he wants', next_node: 11112});

    world.write_model(@NodeMeta{ id: 1121, text: 'Grumpy man', gambling_node: false, is_ending: false});
    world.write_model(@Choice{ node_id: 1121, choice_id: 1, text: 'Confront him', next_node: 11211});
    world.write_model(@Choice{ node_id: 1121, choice_id: 2, text: 'Ignore him', next_node: 11212});

    world.write_model(@NodeMeta { id: 11111, text: 'Home p.2', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 11111, choice_id: 1, text: 'Go to sleep', next_node: 111111});

    world.write_model(@NodeMeta { id: 11112, text: 'Good old friend', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 11112, choice_id: 1, text: 'Go back home', next_node: 111121});

    world.write_model(@NodeMeta { id: 11211, text: 'Confrontation with a man', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 11211, choice_id: 1, text: 'Go back home', next_node: 112111});

    world.write_model(@NodeMeta { id: 11212, text: 'Brawl with a man', gambling_node: false, is_ending: false});
    world.write_model(@Choice { node_id: 11212, choice_id: 1, text: 'Go back home', next_node: 112121});

    world.write_model(@NodeMeta { id: 111111, text: 'End of ch. 1 - Home', gambling_node: false, is_ending: true});
    world.write_model(@NodeMeta { id: 111121, text: 'End of ch. 1 - Old Friend', gambling_node: false, is_ending: true});
    world.write_model(@NodeMeta { id: 112111, text: 'End of ch. 1 - Confronation', gambling_node: false, is_ending: true});
    world.write_model(@NodeMeta { id: 112121, text: 'End of ch. 1 - Brawl', gambling_node: false, is_ending: true});




}