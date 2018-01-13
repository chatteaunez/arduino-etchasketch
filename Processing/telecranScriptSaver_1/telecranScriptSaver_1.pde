int timer;
boolean rec;
PVector prev;
PVector screenRatio = new PVector(5, 3.5);

// String List a l'avantage d'être extensible, on n'est pas limité a uncertain nombre d'entrées
StringList text;


void setup() {
  size(1000, 700);
  background(#989686);

  // on initialist la stringlist
  text = new StringList();
}

void draw() {

  // si on enregistre
  if (rec) {
    if (timer==0) {
      // lors de la première frame il faut initialiser l'array avec "["
      text.append("[");
    } else {
  
      float deltaX = map(mouseX-prev.x, 0, width/screenRatio.x, 0,TAU);
      float deltaY = map(prev.y-mouseY, 0, height/screenRatio.y, 0,TAU);
      // la partie funky, on dessine le trait \o/
      stroke(255);
      strokeWeight(3);
      line(prev.x, prev.y, mouseX, mouseY);

      // on ajoute une ligne à la stringlist, qui est un objet JSON
      // Cet objet comporte 3 variable a chaque fois :
      // t = la frame à laquelle on est (le temps)
      // x = la position de la souris en X
      // y = la position de la souris en Y
      text.append("{\"t\":"+timer+",\"x\":"+deltaX+",\"y\":"+deltaY+"},");
    }
    // on conserve la position actuelle pour dessiner le prochain trait
    prev = new PVector(mouseX, mouseY);
    // on incrémente le timer
    timer++;
  }
}

void mousePressed() {
  // quand on clique, remet les machins a zéro, et on commence à enregistrer
  rec=true;
  timer=0;
  background(0);
  text.clear();
}

void mouseReleased() {
  // quand on lâche le clique, on arrete d'enregistrer
  rec=false;

  // il faut ajouter "]" a la dernière ligne pour fermer l'array JSON
  String last = text.get(text.size()-1);
  text.set(text.size()-1, last.substring(0, last.length()-1)+"]");

  // on transfert la stringlist dans un Array de strings pour l'exporter
  String[] json = new String[text.size()];
  for (int i=0; i<text.size(); i++) {
    String line = text.get(i);
    println(line);
    json[i] = line;
  }

  // On enregistre notre fichier json
  saveStrings("test.json", json);
}