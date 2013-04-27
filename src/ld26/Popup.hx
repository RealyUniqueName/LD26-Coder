package ld26;

import nme.display.Sprite;
import nme.Lib;
import ru.stablex.ui.widgets.Floating;


/**
* Popups
*
*/
class Popup extends Floating{
    static public inline var ANIM_TIME = 1;

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
        //animate
        this.tween(ANIM_TIME, {
            left : 0,
            top  : 0
        }, "Back.easeOut");
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
        this.tween(ANIM_TIME, {
            top  : Lib.current.stage.stageHeight,
            left : Lib.current.stage.stageWidth
        }, "Back.easeIn").onComplete(this.free, [true]);
    }//function close()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Popup