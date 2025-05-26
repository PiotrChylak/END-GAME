use stwo_the_end::models::{NodeMeta, Choice};
use dojo::model::ModelStorage;

pub fn tree_constructor(mut world: dojo::world::WorldStorage) {
    world.write_model(@NodeMeta{ id: 1, text: 'starting node', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 1, choice_id: 1, text: 'go to 11', next_node: 11 });
    world.write_model(@Choice { node_id: 1, choice_id: 2, text: 'go to 12', next_node: 12 });

    world.write_model(@NodeMeta{ id: 11, text: 'node 11', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 11, choice_id: 1, text: 'go to 111', next_node: 111 });
    world.write_model(@Choice { node_id: 11, choice_id: 2, text: 'go to 121', next_node: 121 });

    world.write_model(@NodeMeta{ id: 12, text: 'node 12', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 12, choice_id: 1, text: 'go to 121', next_node: 121 });
    world.write_model(@Choice { node_id: 12, choice_id: 2, text: 'go to 122', next_node: 122 });

    world.write_model(@NodeMeta{ id: 111, text: 'node 111', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 111, choice_id: 1, text: 'go gamble 5', next_node: 5 });

    world.write_model(@NodeMeta{ id: 112, text: 'node 112', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 112, choice_id: 1, text: 'go gamble 10', next_node: 10 });

    world.write_model(@NodeMeta{ id: 121, text: 'node 121', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 121, choice_id: 1, text: 'go gamble 15', next_node: 15 });

    world.write_model(@NodeMeta{ id: 122, text: 'node 122', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 122, choice_id: 1, text: 'go gamble 20', next_node: 20 });

    world.write_model(@NodeMeta{ id: 5, text: 'gambling node 1_1 (5)', gambling_node: true ,is_ending: false });
    world.write_model(@Choice { node_id: 5, choice_id: 1, text: 'Gamble (5)', next_node: 1111 });
    world.write_model(@Choice { node_id: 5, choice_id: 2, text: 'Skip (5)', next_node: 1111 });

    world.write_model(@NodeMeta{ id: 10, text: 'gambling node 1_2 (10)', gambling_node: true ,is_ending: false });
    world.write_model(@Choice { node_id: 10, choice_id: 1, text: 'Gamble (10)', next_node: 1121 });
    world.write_model(@Choice { node_id: 10, choice_id: 2, text: 'Skip (10)', next_node: 1121 });

    world.write_model(@NodeMeta{ id: 15, text: 'gambling node 1_3 (15)', gambling_node: true ,is_ending: false });
    world.write_model(@Choice { node_id: 15, choice_id: 1, text: 'Gamble (15)', next_node: 1211 });
    world.write_model(@Choice { node_id: 15, choice_id: 2, text: 'Skip (15)', next_node: 1211 });

    world.write_model(@NodeMeta{ id: 20, text: 'gambling node 1_4 (20)', gambling_node: true ,is_ending: false });
    world.write_model(@Choice { node_id: 20, choice_id: 1, text: 'Gamble (20)', next_node: 1221 });
    world.write_model(@Choice { node_id: 20, choice_id: 2, text: 'Skip (20)', next_node: 1221 });

    world.write_model(@NodeMeta{ id: 1111, text: 'node 1111', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 1111, choice_id: 1, text: 'go to 11111', next_node: 11111 });
    world.write_model(@Choice { node_id: 1111, choice_id: 2, text: 'go to 11112', next_node: 11112 });

    world.write_model(@NodeMeta{ id: 1121, text: 'node 1121', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 1121, choice_id: 1, text: 'go to 11211', next_node: 11211 });
    world.write_model(@Choice { node_id: 1121, choice_id: 2, text: 'go to 11212', next_node: 11212 });

    world.write_model(@NodeMeta{ id: 1211, text: 'node 1211', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 1211, choice_id: 1, text: 'go to 12111', next_node: 12111 });
    world.write_model(@Choice { node_id: 1211, choice_id: 2, text: 'go to 12112', next_node: 12112 });

    world.write_model(@NodeMeta{ id: 1221, text: 'node 1221', gambling_node: false ,is_ending: false });
    world.write_model(@Choice { node_id: 1221, choice_id: 1, text: 'go to 12211', next_node: 12211 });
    world.write_model(@Choice { node_id: 1221, choice_id: 2, text: 'go to 12212', next_node: 12212 });

    world.write_model(@NodeMeta{ id: 11111, text: 'final node 11111', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 11112, text: 'final node 11112', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 11211, text: 'final node 11211', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 11212, text: 'final node 11212', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 12111, text: 'final node 12111', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 12112, text: 'final node 12112', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 12211, text: 'final node 12211', gambling_node: false ,is_ending: true });
    world.write_model(@NodeMeta{ id: 12212, text: 'final node 12212', gambling_node: false ,is_ending: true });
}