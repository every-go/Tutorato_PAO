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
  title: "Tutorato 5",
  date: "17 Novembre 2026",
)

#filled-slide()[
  Ereditarietà
]

#slide(title: "Classi e derivate")[
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      class orario{
        public:
          orario(int o =0, int m =0, int s =0);
          int Ore() const;
          int Minuti() const;
          int Secondi() const;
          orario operator+(const orario&) const;
        private:
          int sec;
      };
      ```
    ],
    [
      ```cpp
      class dataora : public orario{
        public:
          int Giorno() const;
          int Mese() const;
          int Anno() const;
        private:
          int giorno, mese, anno;
      };
      ```
    ]
  )
]

#slide(title: "Definizioni")[
 -  _orario_ è classe *base*;
 - _orario_ è *superclasse (supertipo)* di _dataora_;
 - _dataora_ classe *derivata (sottotipo)* da _orario_;
 - _public_ è parola chiave (assieme a protected e private);
 - ogni oggetto di _dataora_ contiene come *sottooggetto* un oggetto di _orario_, ovvero i metodi e i membri ereditati possono essere utilizzati (se accessibili) come fossero membri propri;
 - l'insieme delle classi (con derivazioni) consiste nella *gerarchia di classi*;
 - x è un *sottotipo proprio* di y se $x<y$ nella gerarchia.
]

#slide(title: "Caratteristica fondamentale")[
  *Con la derivazione pubblica, ogni oggetto della classe derivata è utilizzabile anche come oggetto della classe base.*\
  Vale anche per riferimenti e puntatori: un riferimento (o un puntatore) a un oggetto di classe derivata può essere convertito implicitamente in un riferimento (o puntatore) a un oggetto della classe base.\
  Il contrario *non* vale.\
  Con la derivazione privata o protetta la conversione è illegale anche verso la base.
]

#slide(title: "Problematica")[
  Uno degli aspetti ironici della programmazione ad oggetti di C++ è che occorre usare puntatori e riferimenti e non oggetti.\
  Esempio:
  ```cpp
  class B{
    public:
      int ore;
      B(int o=0): ore(o) {}
  };
  class D : public B{
    public:
      int minuti;
      D(int min=0): minuti(min) {}
  };
  int main(){
    D d(50);
    B b(10);
    b = d; //estrae a livello di memoria da d il sottooggetto di tipo B ignorando l'ulteriore informazione della classe D
    d = b; //illegale
  }
  ```
]

#slide(title: "Tipo statico e dinamico")[
  D sottoclasse di B.
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      D d; B b;
      D* pd=&d;
      B* pb=&b;
      pb=pd;
      ```
    ],
    [
      ```cpp
      D d; B b;
      D& rd=d;
      B& rb=d; //rb viene definito come alias dell'oggetto d di tipo D, tipo dinamico D&
      ```
    ]
  )
  
  Il tipo B\* viene anche detto il *tipo statico* del puntatore pb.\
  Dopo l'assegnazione pb = pd, _pb_ punta all'oggetto della classe _D_: quindi il tipo *dinamico* di pb è D\*.\
  Il *tipo dinamico* può quindi cambiare a run-time.\
  Da notare che per il compilatore esiste solamente il tipo statico.
]

#slide(title: "Protected")[
  ```cpp
  class orario{
    ...
    protected:
      int sec;
  };
  ```
  La keyword *protected* permette ai membri protetti di risultare accessibili solamente alle classi derivate ma non alle classi esterne.\
  La prassi generale rimane quella di dichiarare privati i campi dati di una classe.
]

#filled-slide()[
  Tipologie di ereditarietà
]

#slide(title: "Accessibilità")[
  Le tipologie di derivazione permettono di modificare i livelli di accessibilità dei membri ereditati dalla classe base.\
  La _derivazione pubblica_ rende i membri della classe base con lo stesso livello di accessibilità anche nella classe derivata.\
  La _derivazione privata_ rende privati nella classe derivata i membri protetti e pubblici della classe base.\
  La _derivazione protetta_ rende protetti nella classe derivata i membri pubblici e protetti della classe base.\
  Le *classi amiche non vengono ereditate*.
  #table(
    columns: (auto, auto, auto, auto),
    [*Derivazione*\
    *Membro*], [_public_], [_protected_], [_private_],
    [_private_], [inaccessibile], [inaccessibile], [inaccessibile],
    [_protected_], [protetto], [protetto], [privato],
    [_public_], [pubblico], [protetto], [privato],
  )
]

#slide(title: "Esempio")[
  ```cpp
  class C{
    private:
      int i;
    protected:
      char c;
    public:
      float f;
  };

  class D : private C {};
  class E : protected C {};

  int main(){
    C c, *pc;
    D d, *pd;
    E e, *pe;
    c = d;      // illegale: derivazione privata, conversione D -> C non accessibile in main
    c = e;      // illegale: derivazione protetta, conversione E -> C non accessibile in main
    pc = &d;    // illegale: D* -> C* non accessibile (derivazione privata)
    pc = &e;    // illegale: E* -> C* non accessibile (derivazione protetta)
    C& rc = d;  // illegale: D& -> C& non accessibile (derivazione privata)
  }
  ```

  La conversione verso la base è legale fuori dalla classe solo con derivazione *pubblica*.
]

#slide()[
  ```
  class C {
    private:
      int priv;
    protected:
      int prot;
    public:
      int publ;
  };
  class D: private C {
    // prot e publ divengono qui privati
  };
  class E: protected C {
    // prot e publ divengono qui protetti
  };
  class F: public D {
    // prot e publ sono qui inaccessibili
    public:
      void fF(int i, int j) {
        prot=i; // Illegale
        publ=j; // Illegale
      }
  };
  class G: public E {
    // prot e publ rimangono qui protetti
    void fG(int i, int j) {
      prot=i; // OK
      publ=j; // OK
    }
  };
  ```
]

#slide()[
    ```cpp
  class C {
    private:
      int i;
    public:
      C(): i(1) {}
    void print() {cout <<' '<<i;}
  };
  class D: public C {
    private:
      double z;
    public:
      D(): z(3.14) {}
      void print() {
        C::print();
        cout <<' ' << z;
      }
  };

  int main() {
    C c; D d;
    c.print(); //stampa: 1
    d.print(); //stampa: 1 3.14
  }
  ```
]

#filled-slide()[
  Ridefinizione di metodi e campi dati
]

#slide(title: "Come funziona")[
  In una classe D, sottotipo proprio di B, è possibile *ridefinire* i campi dati ed i metodi ereditati da B.\
  In D è possibile usare l'operatore di scoping B::b per accedere (se possibile) al membro b definito in B.\
  Tipicamente, la ridefinizione riguarda i metodi ereditati da una classe base.
]

#slide(title: "Esempio")[
  #grid(
    columns: (55%, 45%),
    column-gutter: 5%,
    [
      ```cpp
      class Persona{
        public:
          void saluta() const { cout << "Ciao "; }
      };

      class Studente : public Persona{
        public:
          void saluta() const {     // ridefinizione
            Persona::saluta();
            cout << "studente ";
          }
      };
      ```
    ],
    [
      ```cpp
      int main(){
        Persona p; Studente s;
        p.saluta();           // Ciao
        s.saluta();           // Ciao studente
        s.Persona::saluta();  // Ciao
        p.Studente::saluta(); // illegale
      }
      ```
    ]
  )
]

#slide()[
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      class B{
        public:
          void f() const { cout << "B::f "; }
      };

      class D : public B{
        public:
          void f() const { cout << "D::f "; }
          void soloD() const { cout << "soloD "; }
      };
      ```
    ],
    [
      ```cpp
      int main(){
        D d;
        B* pb = &d;   // tipo statico B*, dinamico D*
        D* pd = &d;
        d.f();        // D::f
        pd->f();      // D::f
        pb->f();      // B::f
        pd->soloD();  // soloD
        pb->soloD();  // illegale
        pd = pb;      // illegale
      }
      ```
    ]
  )

  #text(size: 0.75em)[
      - `pb->f()` chiama `B::f`: conta il tipo *statico* `B*`, non quello dinamico `D*`.
      - `pb->soloD()` è illegale: per il compilatore `pb` è un `B*`, e `B` non ha `soloD`
      - `pd = pb` è illegale: da base a derivata non c'è conversione implicita
  ]
]

#slide()[
  #grid(
    columns: (55%, 45%),
    column-gutter: 5%,
    [
      ```cpp
      class B{
        public:
          int x;
          void g(int i) const { cout << "B::g(int) "; }
      };

      class D : public B{
        public:
          int x;     // ridefinisce B::x
          void g(const string& s) const {
            cout << "D::g(string) ";
          }
      };
      ```
    ],
    [
      ```cpp
      int main(){
        D d;
        d.x = 1;           // D::x
        d.B::x = 2;        // B::x
        cout << d.x << d.B::x;  // stampa: 12
        d.g("ciao");       // D::g(string)
        d.g(5);            // illegale
        d.B::g(5);         // B::g(int)
      }
      ```
    ]
  )
  #text(size: 0.75em)[
    - un campo ridefinito *non sostituisce* quello della base: nell'oggetto `D` ci sono due campi `x`, e `B::x` si raggiunge con lo scoping
    - un nome ridefinito in `D` *nasconde* tutti i membri omonimi di `B`, anche con parametri diversi (non è overloading)
    - `d.g(5)` è illegale: viene trovato solo `D::g(const string&)`, e `int` non si converte in `string`
  ]
]

#filled-slide()[
  Costruttori, assegnazioni e distruttori
]

#slide(title: "Costruttori")[
  - I costruttori *non vengono ereditati*: ogni classe ha i propri
  - Costruzione di un oggetto di `D`, in quest'ordine:
    + il sottooggetto di tipo `B`: costruttore indicato nella lista di inizializzazione, altrimenti quello di *default* di `B`
    + i campi dati propri di `D`, nell'ordine di dichiarazione
    + il corpo del costruttore di `D`
  - La lista di inizializzazione di `D` può inizializzare i campi di `D` e la base con `B(...)`, non i campi ereditati
]

#slide(title: "Costruttori: esempio")[
  #grid(
    columns: (56%, 44%),
    [
      ```cpp
      class B{
        public:
          B(){ cout << "B() "; }
          B(int s){ cout << "B(int) "; }
      };

      class D : public B{
        public:
          int z;
          D(): z(0){ cout << "D() "; }
          D(int n): B(n), z(n){
            cout << "D(int) ";
          }
      };
      ```
    ],
    [
      ```cpp
      int main(){
        D d1;     // B() D()
        D d2(5);  // B(int) D(int)
      }
      ```

      Output: `B() D() B(int) D(int)`

      `D()` non nomina la base: viene invocato `B()` di default.
    ]
  )
]

#slide(title: "Costruttori: casi illegali")[
  #grid(
    columns: (58%, 42%),
    [
      ```cpp
      class B{
        public:
          int i;
          B(int n): i(n) {} // no default
      };

      class D1 : public B{
        public:
          D1() {}             // illegale
      };

      class D2 : public B{
        public:
          D2(int n): i(n) {}  // illegale
      };

      class D3 : public B{
        public:
          D3(): B(1) {}       // OK
      };
      ```
    ],
    [
      ```cpp
      int main(){
        D3 d(5);  // illegale
      }
      ```

      - `D1()`: `B` non ha `B()` e `B(int)` non è invocato
      - `D2(int)`: `i` è un campo di `B`, non si inizializza nella lista di `D2`; va passato a `B(n)`
      - `D3 d(5)`: i costruttori non si ereditano, `D3` ha solo `D3()`
    ]
  )
]

#slide(title: "Costruttore di copia")[
  #text(size: 0.65em)[
    - Se non lo definisci in `D`: quello di default invoca il costruttore di copia di `B` sul sottooggetto, poi copia i campi
    - Se lo definisci in `D`: nella lista di inizializzazione devi scrivere `B(d)`. Se manca, viene invocato il costruttore di *default* di `B`: la parte base *non viene copiata*
  ]
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      class B{
        public:
          int i;
          B(int n=0): i(n) {}
          B(const B& b): i(b.i)
            { cout << "B(const B&) "; }
      };
      class D1 : public B{
        public:
          int z;
          D1(int a=0, int b=0): B(a), z(b) {}
          D1(const D1& d): z(d.z)  // manca B(d)
            { cout << "D1(const D1&) "; }
      };
      ```
    ],
    [
      ```cpp
      class D2 : public B{
        public:
          int z;
          D2(int a=0, int b=0): B(a), z(b) {}
          D2(const D2& d): B(d), z(d.z)
            { cout << "D2(const D2&) "; }
      };
      int main(){
        D1 d1(4,5); D2 d2(4,5);
        D1 e1 = d1;  // e1.i == 0 (!), e1.z == 5
        D2 e2 = d2;  // e2.i == 4, e2.z == 5
      }
      ```
    ]
  )
  #text(size:0.65em)[Output: `D1(const D1&) B(const B&) D2(const D2&)`]
]

#slide(title: "Assegnazione")[
  #text(size: 0.65em)[
    - Se non la definisci in `D`: quella di default invoca `B::operator=` sul sottooggetto, poi assegna i campi
    - Se la definisci in `D`: devi chiamare tu `B::operator=(d)`, altrimenti la parte base *non viene assegnata*
  ]
  #grid(
    columns: (50%, 50%),
    [
      ```cpp
      class B{
        public:
          int i;
          B(int n=0): i(n) {}
          B& operator=(const B& b){
            i = b.i; cout << "B::op= ";
            return *this;
          }
      };
      class D1 : public B{
        public:
          int z;
          D1(int a=0, int b=0): B(a), z(b) {}
          D1& operator=(const D1& d){
            z = d.z;       // manca B::operator=(d)
            cout << "D1::op= ";
            return *this;
          }
      };
      ```
    ],
    [
      ```cpp
      class D2 : public B{
        public:
          int z;
          D2(int a=0, int b=0): B(a), z(b) {}
          D2& operator=(const D2& d){
            B::operator=(d);  // parte base
            z = d.z; cout << "D2::op= ";
            return *this;
          }
      };
      int main(){
        D1 a(1,2), b(3,4); a = b;  // a.i == 1 (!), a.z == 4
        D2 c(1,2), e(3,4); c = e;  // c.i == 3, c.z == 4
        B x;
        a = x;   // illegale
        x = a;   // OK: slicing
      }
      ```
    ]
  )
  #text(size: 0.65em)[Output: `D1::op= B::op= D2::op= B::op=`]
]

#slide(title: "Distruttori")[
  #grid(
    columns: (58%, 42%),
    [
      ```cpp
      class M{
        public:
          M(){ cout << "M() "; }
          ~M(){ cout << "~M() "; }
      };
      class B{
        public:
          B(){ cout << "B() "; }
          ~B(){ cout << "~B() "; }
      };
      class D : public B{
        public:
          M m;
          D(){ cout << "D() "; }
          ~D(){ cout << "~D() "; }
      };
      int main(){
        D d;
      }
      ```
    ],
    [
      Output: `B() M() D() ~D() ~M() ~B()`

      - il distruttore di `D` non si occupa della parte `B`: dopo il corpo di `~D()` e i campi propri viene invocato *in automatico* `~B()`
      - ordine di distruzione *inverso* a quello di costruzione
      - non chiamare `B::~B()` a mano: la base verrebbe distrutta due volte
    ]
  )
]

#slide(title: "Attenzione")[
  ```cpp
  class B{
    public:
      ~B(){ cout << "~B() "; }
  };
  class D : public B{
    public:
      ~D(){ cout << "~D() "; }
  };
  int main(){
    B* p = new D;
    delete p;    // viene invocato solo ~B() (tipo statico): comportamento indefinito
  }
  ```
  Il distruttore giusto viene scelto in base al tipo *statico*: la soluzione sono i distruttori *virtuali* (prossimi argomenti).
]

#slide(title: "Riepilogo")[
  #text(size: 0.75em)[
    #table(
      columns: (auto, 1fr, 1fr),
      inset: 0.5em,
      [*Metodo*], [*Se non lo ridefinisci in `D`*], [*Se lo ridefinisci in `D`*],
      [Costruttore di default], [non ereditato; quello generato invoca `B()`], [invoca `B()` se la lista non nomina la base],
      [Costruttore di copia], [invoca `B(const B&)`, poi copia i campi], [serve `B(d)` nella lista, altrimenti viene invocato `B()`],
      [`operator=`], [invoca `B::operator=`, poi assegna i campi], [serve `B::operator=(d)`, altrimenti la base non viene assegnata],
      [Distruttore], [invoca `~B()` in automatico], [`~B()` è invocato dopo il corpo: non va scritto],
    )
  ]
]