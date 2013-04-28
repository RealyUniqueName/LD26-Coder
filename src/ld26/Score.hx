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
        this.tween(0.5, {top : this.top - 80}, "Quad.easeIn");
        this.tween(2, {
            alpha : 0,
            top   : this.top - 120
        }, 'Linear.easeNone', false)
            .delay(0.5)
            .onComplete(this.free, [true]);
    }//function animate()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Score