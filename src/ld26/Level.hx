package ld26;

import haxe.Timer;
import motion.Actuate;
import ru.stablex.ui.widgets.Widget;



/**
* Level instance
*
*/
class Level extends Widget{

    //game field
    public var field : Widget;
    //features to implement
    public var features : Array<Feature>;
    //current feature
    public var current : Feature;
    //next feature
    public var next : Feature;
    //widget where to show next feature
    public var displayNext : Widget;
    //player's project
    public var project : Project;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Get level components on creation complete
    *
    */
    override public function onCreate () : Void {
        super.onCreate();
        this.field       = this.getChild("field");
        this.project     = this.field.getChildAs("project", Project);
        this.displayNext = this.getChild("displayNext");
    }//function onCreate()


    /**
    * Load level config
    *
    */
    public function load (data:TLevelCfg = null) : Void {
        this.project.load( Project.rnd(3) );
    }//function load()


    /**
    * Start game
    *
    */
    public function start () : Void {
        this.next = Feature.rnd(3);
        //drop first feature
        this.nextFeature();
    }//function start()


    /**
    * Pause game
    *
    */
    public function pause () : Void {
        Actuate.pauseAll();
    }//function pause()


    /**
    * Resume game
    *
    */
    public function resume () : Void {
        Actuate.resumeAll();
    }//function resume()


    /**
    * Create next feature
    *
    */
    public function nextFeature () : Void {
        this.current = this.next;
        this.next    = Feature.rnd(3);
        this.field.addChild(this.current);
        this.displayNext.addChild(this.next);

        this.current.top  = 0;
        this.current.left = this.current.col * Main.cfg.block.size;
        this.current.step();
    }//function nextFeature()


    /**
    * Drop current feature
    *
    */
    public function dropFeature () : Void {
        if( this.current.dropped || this.current.row <= 0 ) return;

        this.current.dropped = true;
        while( this.current.canMove() ){
            this.current.row ++;
        }
        this.current.row --;
        this.current.performStep();
    }//function dropFeature()


    /**
    * Called when feature was stopped. Add feature's blocks to project
    *
    */
    public function featureStopped (f:Feature) : Void {
        //game over
        if( f.row <= 0 ){
            this.gameOver();

        //next feature
        }else{
            this.project.addFeature(f);
            this.nextFeature();
            f.free();
        }
    }//function featureStopped()


    /**
    * Game over
    *
    */
    public function gameOver () : Void {
        //code...
    }//function gameOver()


    /**
    * Try to rotate feature
    * @param left - rotate left(true) or right(false)
    *
    */
    public function rotateFeature (left:Bool = true) : Void {
        //code...
    }//function rotateFeature()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Level