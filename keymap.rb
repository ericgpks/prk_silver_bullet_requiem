# Wait until Keyboard class is ready
while !$mutex
  relinquish
end

# Initialize a Keyboard
kbd = Keyboard.new

# `split=` should happen before `init_pins`
kbd.split = true

# You can make right side the "anchor" (so-called "master")
# kbd.set_anchor(:right)

# Initialize GPIO assign
kbd.init_pins(
  [ 4, 5, 6, 7 ],            # row0, row1,... respectively
  [ 20, 22, 26, 27, 28, 29 ]
)

# default layer should be added at first
kbd.add_layer :default, %i[
  KC_TAB   KC_Q    KC_W       KC_E    KC_R       KC_T            KC_Y        KC_U         KC_I    KC_O         KC_P      KC_EQL
  KC_LSFT  KC_A    KC_S       KC_D    KC_F       KC_G            KC_H        KC_J         KC_K    KC_L         KC_SCOLON KC_QUOT
  KC_LCTL  KC_Z    KC_X       KC_C    KC_V       KC_B            KC_N        KC_M         KC_COMM KC_DOT       KC_SLSH   KC_MINS
  KC_NO    KC_NO   ALT_F5     KC_BSPC SFT_SPC    CALC_ESC        CUSL_TAB    CTRL_ENT     KC_DEL  RUBY_F12     KC_NO     KC_NO
]
kbd.add_layer :cursol, %i[
  KC_NO    KC_F1   KC_F2      KC_PGUP KC_F4      KC_F5           KC_F6       KC_F7        KC_UP   KC_F9        KC_F10    KC_F11
  KC_NO    KC_TILD KC_HOME    KC_PGDN KC_END     KC_LPRN         KC_RPRN     KC_LEFT      KC_DOWN KC_RGHT      KC_PIPE   KC_F12
  KC_NO    KC_GRV  KC_NO      KC_F3   KC_NO      KC_NO           KC_NO       KC_NO        KC_F8   KC_NO        KC_BSLS   KC_NO
  KC_NO    KC_NO   KC_NO      KC_NO   KC_NO      ADJUST          KC_NO       KC_NO        KC_NO   KC_NO        KC_NO     KC_NO
]
kbd.add_layer :calc, %i[
  RESET    KC_1    KC_2       KC_3    KC_4       KC_5            KC_6        KC_7         KC_8    KC_9         KC_0      KC_NO
  KC_NO    KC_AT   KC_HASH    KC_DLR  KC_PERC    KC_LBRC         KC_RBRC     KC_4         KC_5    KC_6         KC_PPLS   KC_NO
  KC_NO    KC_CIRC KC_AMPR    KC_ASTR KC_EXLM    KC_LCBR         KC_RCBR     KC_1         KC_2    KC_3         KC_PEQL   KC_NO
  KC_NO    KC_NO   KC_NO      KC_NO   KC_NO      KC_NO           ADJUST      KC_0         KC_0    KC_PDOT      KC_NO     KC_NO
]
kbd.add_layer :adjust, %i[
  KC_NO    KC_NO   KC_NO      KC_NO   RUBY       KC_NO           KC_NO       KC_NO        KC_NO   KC_NO        KC_NO     KC_NO
  KC_NO    KC_NO   KC_NO      KC_NO   KC_A       KC_NO           RGB_SPI     KC_NO        KC_NO   KC_NO        KC_NO     KC_NO
  KC_NO    KC_NO   KC_NO      KC_NO   KC_NO      KC_NO           RGB_SPD     KC_NO        KC_NO   KC_NO        KC_NO     KC_NO
  KC_NO    KC_NO   KC_NO      KC_NO   KC_NO      KC_NO           KC_NO       KC_NO        KC_NO   KC_NO        KC_NO     KC_NO
]


#                   Your custom     Keycode or             Keycode (only modifiers)      Release time      Re-push time
#                   key name        Array of Keycode       or Layer Symbol to be held    threshold(ms)     threshold(ms)
#                                   or Proc                or Proc which will run        to consider as    to consider as
#                                   when you click         while you keep press          `click the key`   `hold the key`
kbd.define_mode_key :ALT_F5,      [ :KC_F5,                :KC_LALT,                     150,              200 ]
kbd.define_mode_key :SFT_SPC,     [ :KC_SPACE,             :KC_RSFT,                     150,              200 ]
kbd.define_mode_key :CALC_ESC,    [ :KC_ESC,               :calc,                        150,              200 ]
kbd.define_mode_key :CUSL_TAB,    [ :KC_TAB,               :cursol,                      150,              200 ]
kbd.define_mode_key :CTRL_ENT,    [ :KC_ENTER,             :KC_LCTL,                     150,              200 ]
kbd.define_mode_key :RUBY_F12,    [ Proc.new { kbd.ruby }, :KC_RGUI,                     150,              200 ]
kbd.define_mode_key :ADJUST,      [ nil,                   :adjust,                      nil,              nil ]
# `before_report` will work just right before reporting what keys are pushed to USB host.
# You can use it to hack data by adding an instance method to Keyboard class by yourself.
# ex) Use Keyboard#before_report filter if you want to input `":" w/o shift` and `";" w/ shift`
kbd.before_report do
  kbd.invert_sft if kbd.keys_include?(:KC_SCOLON)
  # You'll be also able to write `invert_ctl` `invert_alt` and `invert_gui`
end

# Initialize RGBLED with pin, underglow_size, backlight_size and is_rgbw.
rgb = RGB.new(
  0,    # pin number
  0,    # size of underglow pixel
  22,   # size of backlight pixel
  false # 32bit data will be sent to a pixel if true while 24bit if false
)
# Set an effect
#  `nil` or `:off` for turning off, `:breathing` for "color breathing", `:rainbow` for "rainbow snaking"
rgb.effect = :rainbow
# rgb.effect = :breathing
# Set an action when you input
#  `nil` or `:off` for turning off
# rgb.action = :thunder
# Append the feature. Will possibly be able to write `Keyboard#append(OLED.new)` in the future
kbd.append rgb
kbd.define_mode_key :RGB_SPI,     [ Proc.new { rgb.delay -= 10 if 10 <= rgb.delay; puts rgb.delay }, :KC_LCTL, 300, 400 ]
kbd.define_mode_key :RGB_SPD,     [ Proc.new { rgb.delay += 10;                    puts rgb.delay }, :KC_LCTL, 300, 400 ]

kbd.start!
