




// class Choice {
//   Choice(this.id, this.name);
//   final int id;
//   final String name;
//   // related achivement
// }

// class Scene {
//   Scene(this.index, this.skipChoices,this.actionChoices);
//   final int index;
//   final List<Choice> actionChoices;
//   final List<Choice> skipChoices;
// }

// class SceneManager {

//   List<Scene> scenes = [];
//   Scene? currentScene;
//   Choice? currentChoice;

//   void loadSceneData() {
//     var scene = Scene(0, [Choice(0, 'skip')],[Choice(0, 'action')]);
//     scenes.add(scene);

//     currentScene = scene;
//   }


//   void changeScene() {}
//   void changeChoice() {}
// }