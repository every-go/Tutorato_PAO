#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#show raw.where(block: true, lang: none): it => raw(it.text, lang: "cpp", block: true)
#show raw.where(lang: "cpp"): set text(size: 0.65em)
#let size(s, body) = {
  show raw: set text(size: s)
  body
}

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 6",
  date: "24 Novembre 2026",
)

#filled-slide[
  Ereditarietà e template
]

#slide(title: "Modalità")[
  Sia la classe base che la classe derivata possono essere definite come template di classe.
  + Classe base template e classe derivata (non template) da una istanza della classe base
  + Classe base non template e classe derivata template
  + Classe base e classe derivata entrambe template
  + NON si può derivare da un template di classe senza istanziarlo: `class derivata : public base` è illegale se _base_ è un template
]

#slide(title: "Modalità 1")[
  #show raw: set text(size: 2em)

  ```cpp
  template<class T>
  class base { ... };

  class derivata : public base<int> { ... };
  ```
  \ \
  Ogni oggetto della classe _derivata_ contiene come sottooggetto un oggetto dell'istanza base\<int\> della classe template _base_
]

#slide(title: "Modalità 2")[
  #show raw: set text(size: 2em)
  ```cpp
  class base{ ... };

  template<class T>
  class derivata : public base{ ... };
  ```
  \ \
  Ogni oggetto di ogni istanza della classe template _derivata_ contiene come sottooggetto un oggetto della classe _base_
]

#slide(title: "Modalità 3")[
  #show raw: set text(size: 2em)
  ```cpp
  template <class T>
  class base { ... };

  template <class Tp>
  class derivata : public base<Tp> { ... };
  ```
  I parametri della classe template _derivata_ devono essere *sovrainsieme* di quelli della classe _base_.\
  Ogni oggetto di ogni istanza della classe _derivata_ contiene come sottooggetto un oggetto dell'istanza associata della classe template _base_.
]

#slide(title: "Attenzione")[
  ```cpp
  template <class T> class B {
    public:
      int m;
      int n;
      int f() {}
      int g() {}
  };
  int n = 1; //variabile globale
  int g() {} //funzione globale

  template <class T> class D : B<T> {
    public:
      void h() {
        // m = 2;           ILLEGALE
        this->m = 2;
        // f();             ILLEGALE
        this->f();
        n = 3;              //Assegnazione a n globale
        this->n = 3;        //Assegnazione al campo dati B::n
        g();                //Invoca g() globale
        this->g();          //Invoca il metodo B::g()
      }
  };
  ```
]

#filled-slide[
  Metodi virtuali
]

#slide(title: "Realizzazione del polimorfismo")[
  Il vero polimorfismo si realizza solamente con i metodi *virtual*, serve per utilizzare un metodo in base al tipo *dinamico* del parametro.
  ```
  class orario {
    public:
      virtual void stampa() const { ... }
  };
  class dataora : public orario {
    public:
      virtual void stampa() const { ... }
  };
  void g(const orario& o) { o.stampa(); }
  int main(){
    orario o;
    dataora d;
    g(o);       //chiama orario::stampa()
    g(d);       //chiama dataora::stampa()
    orario *p = &d;
    p->stampa(); //chiama dataora::stampa()
  }
  ```
  Il metodo virtuale da invocare effettivamente verrà selezionato solamente a tempo di esecuzione e non staticamente dal compilatore: *dynamic binding*.
]

#slide(title: "Progettazione")[
  Marcando *virtuale* un metodo m() di una classe base B, il progettista:
  - delega alle sottoclassi di B la ridefinizione di m()
  - affida alla particolare sottoclasse il compito di implementare m() in modo specifico
  La ridefinizione di un metodo virtuale viene anche detta *overriding*.\
  Se una sottoclasse non ridefinisce un metodo virtuale (un metodo virtuale è tale per tutta la gerarchia di classi) allora viene ereditata la definizione presente nella *superclasse diretta*.
]

#slide(title: "Errore")[
  ```cpp
  class B{};
  class D : public B{
    public:
      virtual void m() {}
  };

  int main(){
    B b;
    D d;
    B* p = &d;
    p->m(); //illegale
  }
  ```
  m() non esiste in B: il compilatore ragiona solo sul tipo statico (B\*) e non sa che p punta a un D (risolvibile con i *dynamic_cast*)
]

#slide(title: "Ridefinizioni e overriding")[
  Nell'overriding bisogna prestare attenzione alla segnatura dei metodi.\
  L'overriding in una classe _D_ derivata da _B_ deve mantenere lo stesso nome, la stessa lista di parametri (e lo stesso `const`) e lo stesso tipo di ritorno.\
  Un tentativo di ridefinire con la stessa lista di argomenti ma con tipo di ritorno diverso provoca un errore di compilazione.\
  Oltretutto, un metodo di _D_ con lo stesso nome di un metodo di _B_ nasconde tutti gli overloading di _B_ (visti da _D_), che restano però raggiungibili con `B::`.
]

#slide()[
  Tutto è *public* in questo esempio.
  #grid(
    columns: (50%, 50%),
    [
      ```
      class B{
        virtual int f() {cout<<"B::f()\n"; return 1;}
        virtual void f(string s) {cout<<"B::f(string)\n"; }
        virtual void g() {cout<<"B::g()\n"; }
      };
      class D1: public B{
        //overriding di un metodo virtuale non sovraccaricato
        void g() override {cout<<"D1::g()\n"; }
      };
      class D2: public B{
        //overriding di un metodo virtuale sovraccaricato
        virtual int f() {cout<<"D2::f()\n"; return 2;}
      };
      class D3: public B{
        // NON è possibile modificare il tipo di ritorno
        void f() {cout<<"D3::f()\n"; } //ILLEGALE
      };
      class D4: public B{
        //lista degli argomenti modificata
        //ridefinizione, non overriding
        int f(int) {cout<<"D4::f(int)\n"; return 4;}
      };
      ```
    ],
    [
      ```cpp
      int main(){
        string s="ciao"; D1 d1; D2 d2; D4 d4;
        int x = d1.f();     //stampa B::f()
        d1.f(s);            //stampa B::f(string)
        x = d2.f();         //stampa D2::f()
        d2.f(s);            //ILLEGALE, f() copre anche f(string) di B
        x = d4.f(1);        //stampa D4::f(int)
        x = d4.f();         //ILLEGALE
        d4.f(s);            //ILLEGALE
        B& br = d4;
        br.f(1);            //ILLEGALE, in B non esiste f(int)
        br.f();             //OK, stampa B::f()
        br.f(s);            //OK, stampa B::f(string)
        br.B::f();          //OK, stampa B::f(), static binding
      }
      ```
    ]
  )
]

#slide(title: "Eccezione alla regola")[
  Se $Y<X$ l'overriding di m() in Y può cambiare il tipo di ritorno in Y\* mentre deve sempre mantenere la lista di parametri.\
  Questa possibilità esiste anche con i riferimenti.
  ```cpp
  virtual X* m(T1, ..., Tn);   // in X
  virtual Y* m(T1, ..., Tn);   // in Y (Y sottotipo di X)
  ```
]

#slide(title: "Parametri di default")[
  #grid(
    columns:(50%,50%),
    column-gutter: 2%,
    [
      ```cpp
      class B{
        public:
          virtual void m(int x=0) {cout << "B::m " << x;}
      };
      class D1 : public B{
        public:
          // override senza default: D1 d; d.m(); è ILLEGALE,
          // con un B* o un B& si usa il default x=0 di B
          virtual void m(int x) {cout << "D1::m " << x;}
      };
      class D2 : public B {
        public:
          //nuovo metodo
          virtual void m() {cout << "D2::m ";}
      };
      class D3 : public B{
        public:
          //override con un nuovo default: vale solo se il tipo statico è D3
          virtual void m(int x=5){cout<< "D3::m " << x;}
      };
      ```
    ],
    [
      ```
      int main() {
      B b; D1 d1; D2 d2; D3 d3;
      b.m();     // B::m 0
      b.m(7);    // B::m 7
      // d1.m(); // ERRORE: non ha argomento di default
      d1.m(7);   // D1::m 7
      d2.m();    // D2::m  (chiama il nuovo metodo m() di D2)
      // d2.m(7); // ERRORE: D2::m() nasconde B::m(int)
      d3.m();    // D3::m 5  (tipo statico D3 -> usa il default 5 di D3)
      d3.m(7);   // D3::m 7
      B* pb1 = &d1;
      pb1->m();    // D1::m 0 -> default di B (0), ma funzione virtuale di D1!
      pb1->m(7);   // D1::m 7
      B* pb2 = &d2;
      pb2->m();    // B::m 0  -> D2::m() non fa override di B::m(int)
      pb2->m(7);   // B::m 7
      B* pb3 = &d3;
      pb3->m();    // D3::m 0 -> tipo statico B* (default 0), ma funzione virtuale di D3!
      pb3->m(7);   // D3::m 7
      B& rb1 = d1, rb3 = d3;
      rb1.m();   // D1::m 0
      rb3.m();   // D3::m 0
    }
    ```
    ]
  )
  
]

#filled-slide[
  vtable
]

#slide(title: "vtable")[
  Il late binding implica un overhead dinamico a run-time in termini di spazio e tempo (attualmente trascurabile).\
  Per ogni classe C che contiene almeno un metodo virtuale, il compilatore crea una tabella contenente gli indirizzi dei metodi virtuali di C (puntatori a funzioni), denominata *vtable*.
]

// ---------- Helper per il disegno della vtable ----------
#let giallo = rgb("#ffd966")
#let cella(body, fill: none) = box(
  stroke: 0.6pt, inset: 6pt, fill: fill,
  if fill == none { body } else { text(fill: black, body) },
)
#let freccia = text(size: 1.2em)[#sym.arrow.long.r]

#slide(title: "Esempio: classi e vtable")[
  #grid(
    columns: (56%, 41%),
    column-gutter: 3%,
    [
      ```cpp
      class B {
        public:
          virtual void f() { cout << "B::f "; }
          virtual void g() { cout << "B::g "; }
          void h() { cout << "B::h "; }
      };
      class D : public B {
        public:
          void f() override { cout << "D::f "; }
          virtual void k() { cout << "D::k "; }
      };
      ```
    ],
    [
      *vtable di `B`*
      #table(
        columns: (auto, 1fr),
        inset: 0.4em,
        [`[0] f`], [`B::f`],
        [`[1] g`], [`B::g`],
      )
      *vtable di `D`*
      #table(
        columns: (auto, 1fr),
        inset: 0.4em,
        [`[0] f`], [`D::f`],
        [`[1] g`], [`B::g`],
        [`[2] k`], [`D::k`],
      )
    ],
  )
  #text(size: 0.75em)[
    - Una vtable per classe; ogni oggetto ha un puntatore nascosto, il `vptr`, a quella della sua classe
    - `D` cambia la voce di `f` (override), lascia `g` su `B::g` e aggiunge `k`. `h` non è virtuale: non è in nessuna vtable
  ]
]

#slide(title: "Esempio: chiamate")[
  #grid(
    columns: (48%, 49%),
    column-gutter: 3%,
    [
      ```cpp
      int main() {
        B b; D d;
        B* p = &d;
        p->f();   // D::f
        p->g();   // B::g
        p->h();   // B::h
        p->k();   // ILLEGALE
        p = &b;
        p->f();   // B::f
      }
      ```
      Output: `D::f B::g B::h B::f`
    ],
    [
      #text(size: 0.85em)[
        - `p->f()`: virtuale, quindi si usa la vtable dell'oggetto *puntato*: è un `D`, e la sua voce `f` è `D::f`
        - `p->g()`: stessa vtable di `D`, voce `g`: `B::g`, perché `D` non ha fatto override
        - `p->h()`: non virtuale, il compilatore sceglie `B::h` dal tipo *statico* `B*`: non si guarda la vtable
        - `p->k()`: illegale. La vtable di `D` contiene `k`, ma il compilatore controlla solo il tipo statico `B*`, e `B` non ha `k`
        - dopo `p = &b`, il `vptr` dell'oggetto puntato è quello di `B`: `p->f()` dà `B::f`
      ]
    ],
  )
]

#slide(title: "Esempio: come funziona")[
  #text(size: 0.8em)[
    #grid(
      columns: (auto, auto, auto, auto, auto, auto, auto),
      column-gutter: 0.4em,
      row-gutter: 0.4em,
      align: horizon + center,
      [tipo statico `B*`], [], [oggetto `d` (tipo `D`)], [], [vtable di `D`], [], [codice],
      cella(fill: giallo)[`p`], freccia, cella(fill: giallo)[`vptr`], freccia, cella(fill: giallo)[`[0] f`], freccia, cella(fill: giallo)[`D::f`],
      [], [], cella[`campi di B`], [], cella[`[1] g`], freccia, cella[`B::g`],
      [], [], cella[`campi di D`], [], cella[`[2] k`], freccia, cella[`D::k`],
    )

    Esecuzione di `p->f()` con `B* p = &d;`:
    + `f` è virtuale: la scelta non viene fatta dal compilatore
    + a run-time si segue il `vptr` dell'oggetto *puntato* (un `D`) e si arriva alla vtable di `D`
    + si prende la voce di `f` (la `[0]`) e si salta a quel codice: `D::f`
  ]
]

#filled-slide[
  Distruttori virtuali
]

#slide(title: "Come funzionano")[
  ```cpp
  D* pd = new D();
  B* pb = pd;
  delete pb;
  ```
  Se il distruttore di B *non* è virtuale, _delete pb_ richiama soltanto il distruttore della classe base B su un oggetto della classe derivata D (comportamento indefinito).\
  Si può evitare dichiarando virtuale il distruttore della classe base B: in questo modo, tutti i distruttori delle classi derivate da B diventano automaticamente virtuali ottenendo quindi l'effetto che quando viene applicato l'operatore _delete_ ad un puntatore alla classe base B il cui tipo dinamico è D\*, viene effettivamente invocato il distruttore di D.
]

#slide(title: "Esempio")[
  ```cpp
  class B{
    public:
      virtual ~B() {cout<<"~B";}
  };
  class C : public B{
    public:
      ~C() {cout<<"~C";}
  };
  int main(){
    C* q = new C();
    B* p = q;         //tipo statico B*, tipo dinamico C*
    delete p;         //stampa ~C~B
  }
  ```
]

#slide(title: "Per chiamate a metodi")[
  Nel caso in cui il distruttore e/o il costruttore includano chiamate a metodi, quella invocazione si riferisce sempre alla versione definita nella classe stessa, senza late binding.\
  Si può fare anche nel codice, utile per quando si vuole usare obbligatoriamente una funzione specifica.
]

#filled-slide[
  Metodi virtuali puri
]

#slide(title: "A cosa servono")[
  #text(size: 0.75em)[
    Servono a definire classi base per le quali *non puoi usare i suoi oggetti* poiché necessitano di definizioni più specifiche nelle classi derivate.\
    Definisce la lista delle operazioni basilari che ogni classe derivata può fare.
  ]
  Esempio:
  ```cpp
  class Shape{
    public:
      virtual void draw() =0;
  };
  class Window: public Shape{
    public:
      void draw() override {}
  };
  class Icon: public Shape{
    public:
      void draw() override{}
  };
  int main(){
    Shape s; //ILLEGALE
    Shape* w = new Window;
    w->draw();
    Shape* i = new Icon;
    i->draw();
  }
  ```
]

#slide(title: "Progettazione")[
  Non tutte le gerarchie di classi "sensate" sono obbligate ad avere delle classi astratte, ma se ci sono, solitamente la definizione avviene nelle "classi più alte".\
  Non ci sono limitazioni nelle classi astratte: si possono avere 5 classi astratte prima di averne una concreta (ha senso, non ha senso? dipende dal dominio...).
]

#slide(title: "Esempio gerarchia di classi")[
  #image(
    "images/Schema_modello_logico.jpg"
  )
]

#filled-slide[
  RTTI (Run Time Type Identification)
]

#slide(title: "A cosa serve")[
  Permette di determinare il tipo dinamico di un puntatore o di un riferimento a run-time.\
  Operatori principali:
  - typeid
  - dynamic_cast
]

#slide(title: "typeid")[
  Permette di determinare il tipo di una espressione qualsiasi a tempo di esecuzione.\
  Ritorna un oggetto _type_info_ che rappresenta il tipo di quell'espressione: dinamico se è un oggetto polimorfo, statico altrimenti.
  ```cpp
  cout << typeid(1).name() << endl;     //stampa i(nt)
  cout << typeid(3.14).name() <<endl;   //stampa d(ouble)
  if(typeid(1) == typeid(int)){
    cout<< "Yes";                       //stampa "Yes"
  }
  ```
  È possibile soltanto confrontare oggetti _type_info_ con gli operatori di uguaglianza e disuguaglianza ed estrarne il "nome" tramite il metodo _name()_.
]

#slide(title: "Regole")[
  Reminder: una classe è polimorfa se e solo se avviene una di queste:
  + ha almeno un metodo virtuale
  + eredita da una classe polimorfa
  Le regole alle quali prestare attenzione sono le seguenti:
  - se la classe non è polimorfa, _typeid_ restituisce sempre il tipo statico dell'espressione (con `typeid(*p)` e `p` di tipo `B*`, il tipo `B`)
  - _typeid_ su un puntatore *non dereferenziato* restituisce sempre il tipo statico del puntatore (`B*`)
  - _typeid_ ignora sempre l'attributo di tipo _const_: ad esempio typeid(T) == typeid(const T) è *true*
]

#slide(title: "dynamic_cast")[
  ```cpp
  B b; D d;              // D sottotipo di B, B polimorfa
  B* p = &d;
  B* q = &b;
  dynamic_cast<D*>(p)    // D*: l'oggetto puntato è un D
  dynamic_cast<D*>(q)    // nullptr: l'oggetto puntato è un B, non un D
  ```
  - dynamic_cast\<D\*\>(p) ha successo se il tipo *dinamico* dell'oggetto puntato da _p_ è _D_ (o un suo sottotipo): ritorna un puntatore di tipo D\* allo stesso oggetto
  - altrimenti la conversione fallisce e ritorna *nullptr*
  - nel caso dei riferimenti, se il tipo dinamico non è _D_ (o un suo sottotipo), il dynamic_cast fallisce e viene lanciata un'eccezione di tipo _bad_cast_
  - la classe di partenza (qui _B_) deve essere polimorfa, altrimenti non compila
]

#slide(title: "Esempio")[
  #grid(
    columns: (50%, 50%),
    [
      ```
      class impiegato{
        public:
          virtual double stipendioBase() const = 0;
      };
      class manager : public impiegato{
        public:
          virtual double stipendioBase() const { return 2000; }
      };
      class programmatore : public impiegato{
        public:
          virtual double stipendioBase() const { return 1500; }
          virtual double bonus() const { return 300; }
      };
      ```
    ],
    [
      ```
      class softwareHouse{
        public:
          static double stipendio(const impiegato& p){
            const programmatore* q = 
              dynamic_cast<const programmatore*>(&p);
            if(q){
              return q->stipendioBase() + q->bonus();
            }
            else{
              return p.stipendioBase();
            }
          }
      };
      ```
    ]
  )
  ```
  int main(){
    manager m; programmatore p;
    cout << "Il manager guadagna " << softwareHouse::stipendio(m) <<endl;
    cout << "Il programmatore guadagna " << softwareHouse::stipendio(p) << endl;
  }
  ```
  
]