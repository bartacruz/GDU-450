# PFD Selectable UI Element.
# Similar to a TextElement, but instead of blinking, the highlightElement() 
# method just switchs styles once.


var SelectableElement = 
{
 new : func (pagename, svg, name, value="", style=nil)
  {
    var obj = { 
      parents : [ SelectableElement, PFD.UIElement ],
      _name : pagename ~ name,
      _edit : 0,
      _style : style,
    };

    if (style == nil) obj._style = PFD.DefaultStyle;

    obj._symbol = svg.getElementById(obj._name);
    if (obj._symbol == nil) die("Unable to find element " ~ obj._name);
    # obj.setValue(value);

    # State and timer for flashing highlighting of elements
    obj._highlighted = 0;
    obj._flash = 0;

    # Text to assign at the end of the highlight period.
    # Used for annunicators that should flash and then change value.
    obj._endText = nil;

    return obj;
  },

  getName : func() { return me._name; },
  getValue : func() {
    if (me._symbol.getText() == nil) return "";  # Special case - canvas text elements return nil instead of empty string
    return me._symbol.getText();
  },
  setValue : func(value) { me._symbol.setText(value); },
  setVisible : func(vis) { me._symbol.setVisible(vis); },
  _flashElement : func() {
    if (me._flash == 0) {
      # me._symbol.setDrawMode(canvas.Text.BOUNDINGBOX);
      # me._symbol.setColorFill(me._style.HIGHLIGHT_COLOR);
      me._symbol.setColor(me._style.HIGHLIGHT_TEXT_COLOR);
      me._flash = 1;
    } else {
      # me._symbol.setDrawMode(canvas.Text.BOUNDINGBOX);
      me._symbol.setColor(me._style.NORMAL_TEXT_COLOR);
      me._flash = 0;
    }
  },
  highlightElement : func(highlighttime=-1, endText=nil) {
	  me._endText = endText;
    me._highlighted = 1;
    me._flash == 0;
    me._flashElement();
  },
  unhighlightElement : func() {
    if (me._endText != nil) me.setValue(me._endText);
    me._endText = nil;
    me._highlighted = 0;
    # me._symbol.setDrawMode(canvas.Text.TEXT);
    me._symbol.setColor(me._style.NORMAL_TEXT_COLOR);
    me._flashElement();

  },
  isEditable : func () { return 0; },
  isInEdit : func() { return 0; },
  isHighlighted : func() { return me._highlighted; },
  enterElement : func() { return me.getValue(); },
  clearElement : func() { },
  editElement : func()  { },
  incrSmall : func(value) { },
  incrLarge : func(value) { },
};