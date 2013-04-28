package ld26;

import nme.display.Sprite;
import nme.Lib;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Floating;
import ru.stablex.ui.widgets.Widget;


/**
* Popups
*
*/
class Popup extends Floating{
    static public inline var ANIM_TIME = 0.6;

    //finger sprite
    private var _finger : Widget;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Show popup
    *
    */
    override public function show () : Void {
        this.leftPt = this.topPt  = 100;
        super.show();

        //add finger
        if( this._finger == null ){
            this._finger = UIBuilder.create(Widget, {
                name          : "finger",
                mouseEnabled  : false,
                mouseChildren : false,
                children      : [
                    UIBuilder.create(Bmp,{
                        src  : "assets/img/finger.png",
                        top  : -30,
                        left : 50
                    })
                ]
            });
            this.addChild(this._finger);
        }

        Sfx.play("popup");

        //animate
        this.tween(ANIM_TIME, {
            left : 0,
            top  : 0
        }, "Quad.easeOut").onComplete(function(){
            this._finger.tween(ANIM_TIME / 3, {top:this.w, left:this.w});
        });
    }//function show()


    /**
    * Close and destroy popup
    *
    */
    public function close () : Void {
        //disable interactions
        for(i in 0...this.numChildren){
            if( Std.is(this.getChildAt(i), Sprite) ){
                cast(this.getChildAt(i), Sprite).mouseEnabled  = false;
                cast(this.getChildAt(i), Sprite).mouseChildren = false;
            }
        }
        //anim
        this._finger.tween(ANIM_TIME / 3, {
            top  : this.h / 2 + 50,
            left : this.w / 2
        }).onComplete(function(){
            Sfx.play("popup");
            this.tween(ANIM_TIME, {
                top  : Lib.current.stage.stageHeight,
                left : Lib.current.stage.stageWidth
            }, "Quad.easeIn").onComplete(this.free, [true]);
        });
    }//function close()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Popup