package ld26;

import ru.stablex.ui.widgets.Text;


/**
* Scores animation
*
*/
class Score extends Text{


/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Start animation
    *
    */
    public function animate () : Void {
        this.tween(0.3, {top : this.top - 60}, "Quad.easeIn");
        this.tween(1, {
            alpha : 0,
            top   : this.top - 90
        }, 'Linear.easeNone', false)
            .delay(0.3)
            .onComplete(this.free, [true]);
    }//function animate()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Score