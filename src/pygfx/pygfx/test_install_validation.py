import pygfx as gfx


def test_pyi_pygfx():
    ff = gfx.font_manager.select_font("foo", gfx.font_manager.default_font_props)[0][1]
    print(ff.codepoints)
    assert len(ff.codepoints) > 100
