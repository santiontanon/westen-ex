/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package westen;


/**
 *
 * @author santi
 */
public class Main {
    public static void main(String args[]) throws Exception
    {
        boolean EXversion = true;
        boolean generateText = false;  // This is slow, so, re-generate only if needed
        
        Floor.main(args);
        Walls.generateWallData(EXversion);
        Doors.main(args);
        Objects.main(args);
        // This should be called after "Objects"
        if (EXversion) {
            RoomsEX.main(args);
            if (generateText) {
                Text.generateTextData(EXversion);
                TextES.generateTextData(EXversion);
                MultilingualTextMap.main(args);
            }
            TiledRoomsEX.main(args);
            SpritesEX.main(args);
            TravelCutscene.main(args);
        } else {
            Rooms.main(args);
            if (generateText) {
                Text.generateTextData(EXversion);
                TextES.main(args);
                TextPTBR.main(args);
            }
            Sprites.main(args);
        }
        Hud.generate(EXversion);
        Enemies.main(args);
        Inventory.generateInventory(EXversion);
    }
}
