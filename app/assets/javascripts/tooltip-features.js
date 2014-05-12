// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
/*global document: false */


var tooltip = function () {
    "use strict";
    var id = 'tt', top = 2, left = 2, maxw = 1800, speed = 10, timer = 20, endalpha = 95, alpha = 0, tt, t, c, b, h;
    var ie = document.all ? true : false;
    return {
        show: function (v, w) {
            if (tt == null) {
                tt = document.createElement('div');
                tt.setAttribute('id', id);
                t = document.createElement('div');
                t.setAttribute('id', id + 'top');
                c = document.createElement('div');
                c.setAttribute('id', id + 'cont');

                tt.appendChild(t);
                tt.appendChild(c);
                document.body.appendChild(tt);
                tt.style.opacity = 0;
                tt.style.filter = 'alpha(opacity=0)';
                document.onmousemove = this.pos;
            }
            tt.style.display = 'block';
            c.innerHTML = v;
            if (!w && ie) {
                t.style.display = 'none';
                tt.style.width = tt.offsetWidth;
                t.style.display = 'block';
            }
            tt.style.width = w ? w + 'px' : 'auto';
            h = parseInt(tt.offsetHeight) + top;
            clearInterval(tt.timer);
            tt.timer = setInterval(function () {
                tooltip.fade(1)
            }, timer);
        },
        pos: function (e) {
            var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
            var l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
            tt.style.top = (u - h) + 'px';
            tt.style.left = (l + left) + 'px';
        },
        fade: function (d) {
            var a = alpha;
            if ((a != endalpha && d == 1) || (a != 0 && d == -1)) {
                var i = speed;
                if (endalpha - a < speed && d == 1) {
                    i = endalpha - a;
                } else if (alpha < speed && d == -1) {
                    i = a;
                }
                alpha = a + (i * d);
                tt.style.opacity = alpha * .01;
                tt.style.filter = 'alpha(opacity=' + alpha + ')';
            } else {
                clearInterval(tt.timer);
                if (d == -1) {
                    tt.style.display = 'none'
                }
            }
        },
        hide: function () {
            if (typeof tt === 'undefined') {
                console.log('tt object Not found!')
            }
            else {
                clearInterval(tt.timer);
                tt.timer = setInterval(function () {
                    tooltip.fade(-1)
                }, timer);
            }
        }
    };
}();




