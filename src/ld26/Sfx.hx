package ld26;

import nme.events.Event;
import nme.media.SoundChannel;
import ru.stablex.Assets;




/**
* Sound manageer
*
*/
class Sfx {

    //description
    static private var _theme : SoundChannel;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/


    /**
    * Start sound
    *
    */
    static public function play (snd:String, showBossSpeech:Bool = false) : SoundChannel {
        var snd = Assets.getSound(
            #if flash
                "assets/snd/" + snd + ".mp3"
            #else
                "assets/snd/" + snd + ".wav"
            #end
        );
        //no sound found
        if( snd == null ) return null;

        return snd.play();
    }//function play()


    /**
    * Start soundtrack
    *
    */
    static public function startTheme (e:Event) : Void {
        if( Sfx._theme != null ) {
            Sfx._theme.removeEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
        }

        Sfx._theme = Sfx.play("theme");
        Sfx._theme.addEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
    }//function startTheme()


    /**
    * Stop soundtrack
    *
    */
    static public function stopTheme () : Void {
        if( Sfx._theme != null ) {
            Sfx._theme.removeEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
            Sfx._theme.stop();
        }
    }//function stopTheme()


/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
    }//function new()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Sfx