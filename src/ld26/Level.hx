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
        this.field   = this.getChild("field");
        this.project = this.field.getChildAs("project", Project);
    }//function onCreate()


    /**
    * Load level config
    *
    */
    public function load (data:TLevelCfg = null) : Void {
        this.project.load( Project.rnd(1) );
    }//function load()


    /**
    * Start game
    *
    */
    public function start () : Void {
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
        this.current = Feature.rnd();
        this.field.addChild(this.current);
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

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Level