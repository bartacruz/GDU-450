var BarElement = {
 new : func (pagename, svg, name, maxsize, value=0, style=nil, minval=0,maxval=1,) {
    var obj = { 
      parents : [ BarElement, PFD.UIElement ],
      _name : pagename ~ name,
      _edit : 0,
      _style : style,
      _minval: minval,
      _maxval: maxval,
      _maxsize: maxsize,
      
    };
    # State and timer for flashing highlighting of elements
    obj._highlighted = 0;
    obj._flash = 0;

    if (style == nil) obj._style = PFD.DefaultStyle;

    obj._symbol = svg.getElementById(obj._name);
    if (obj._symbol == nil) die("Unable to find element " ~ obj._name);
    obj.setValue(value);
    return obj;
  },
  setValue: func(val) {
    var factor=0;
    if (val > 0.1) {
        factor = val / me._maxval;
    }
    me._scaleX(me._symbol,factor);
    debug.dump(me._symbol.getSize());
    debug.dump(me._symbol.getScale());
    me._value=val;
  },
  getValue: func() {
    return me._value;
  },
  setVisible : func(vis) { 
    me._symbol.setVisible(vis); 
  },
  getVisible: func() {
    return me._symbol.getVisible();
  },
  _scaleX: func(elem, factor, ref = 'left') {
        elem.updateCenter();
        var (sx, sy) = elem.getScale();
        var (tx, ty) = elem.getTranslation();
        var (xmin, ymin, xmax, ymax) = elem.getTightBoundingBox();
        var x = (ref == 'left') ? xmin : (ref == 'right') ? xmax : (xmin + xmax)/2;
        var u = tx + x*sx;
        print("scaleX: "~factor~"; sx="~sx~" sy="~sy~" tx="~tx~" ty="~ty,
            sprintf(" BB %1.3e, %1.3e, %1.3e, %1.3e, ", xmin, ymin, xmax ,ymax), 
            " u="~u);
        elem.setScale(factor, sy);
        elem.setTranslation(u-x*factor, ty);
        return elem;
  },
};
