#[cfg(test)]
mod tests {
    use dojo_cairo_test::spawn_test_world;

    #[test]
    fn test_spawn_world() {
        let _world = spawn_test_world([].span());
        assert(1 == 1, 'one should equal one');
    }
}
