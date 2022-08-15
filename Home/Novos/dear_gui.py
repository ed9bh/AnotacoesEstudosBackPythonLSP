# https://dearpygui.readthedocs.io/en/latest/tutorials/first-steps.html
# https://www.youtube.com/watch?v=BtKFsp0ShAY
# pip install dearpygui
# pip install dearpygui --no-cache-dir --upgrade --force

import dearpygui.dearpygui as dpg

dpg.create_context()

def action(sender, data):
    input_value = dpg.get_value("Texto")
    print(input_value)

with dpg.window(label = 'Janela Interna', tag='primary'):
    dpg.add_text('Here we go again....')
    dpg.add_input_text(tag='Texto', label = 'Texto', default_value = '...')
    dpg.add_slider_int(label = 'Slider Int', max_value = 100)
    dpg.add_slider_float(label = 'Slider Float', max_value = 100)
    dpg.add_button(label='Teste', tag='Teste', callback = action)
    pass

dpg.create_viewport(title = 'Janela', width = 540, height = 540)
dpg.setup_dearpygui()
dpg.show_viewport()
dpg.set_primary_window('primary', True)
dpg.start_dearpygui()
dpg.destroy_context()

# %%