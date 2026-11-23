#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 6 - Esercizi Extra",
  date: "24 Novembre 2026",
)

// Blocco di codice allineato a sinistra e con dimensione ridotta
#let code(body, size: 0.8em) = {
  show raw: set text(size: size)
  align(left, body)
}

// Opzioni a crocette: A) B) C)
#let opts(..items) = {
  for (i, t) in items.pos().enumerate() [
    *#numbering("A)", i + 1)* #t \
  ]
}

// ---------- Codice degli esercizi "cosa stampa" ----------

// Cosa stampa 1: virtual, parametri di default, costruttori, nascondimento, slicing
#let x1a = ```cpp
class A {
public:
  virtual void f(int x = 1)
    {cout << "A::f" << x << " ";}
  void g() {cout << "A::g "; f();}
  virtual void h() {cout << "A::h ";}
  A() {cout << "A() "; f();}
};
class B: public A {
public:
  void f(int x = 2)
    {cout << "B::f" << x << " ";}
  void h(int y) {cout << "B::h(int) ";}
  B() {cout << "B() "; f();}
};
```

#let x1b = ```cpp
int main() {
  B b; cout << "UNO\n";
  A* p = &b;
  p->f(); cout << "DUE\n";
  p->g(); cout << "TRE\n";
  p->h(); cout << "QUATTRO\n";
  b.h(3); cout << "CINQUE\n";
  A a = b; a.f(); cout << "SEI\n";
}
```

// Cosa stampa 2: template + virtual + distruttore virtuale
#let x2a = ```cpp
template <class T>
class B {
protected:
  T x;
public:
  B(T t): x(t) {cout << "B" << x << " ";}
  virtual ~B() {cout << "~B ";}
  virtual void inc()
    {x = x + 1; cout << "inc" << x << " ";}
  void due() {inc(); inc();}
};
template <class T>
class D: public B<T> {
public:
  D(T t): B<T>(t) {cout << "D ";}
  ~D() {cout << "~D ";}
  void inc()
    {this->x = this->x * 2;
     cout << "dinc" << this->x << " ";}
};
```

#let x2b = ```cpp
int main() {
  B<int>* p = new D<int>(3);
  cout << "UNO\n";
  p->inc(); cout << "DUE\n";
  p->due(); cout << "TRE\n";
  B<double> b(1.5);
  b.due(); cout << "QUATTRO\n";
  delete p; cout << "CINQUE\n";
}
```

// Cosa stampa 3: classe astratta, dynamic_cast, typeid
#let x3a = ```cpp
class Animale {
public:
  virtual ~Animale() {}
  virtual string nome() const =0;
};
class Cane: public Animale {
public:
  string nome() const {return "cane";}
  void abbaia() const {cout << "bau ";}
};
class Gatto: public Animale {
public:
  string nome() const {return "gatto";}
};
class Cucciolo: public Cane {
public:
  string nome() const {return "cucciolo";}
};
```

#let x3b = ```cpp
void f(const Animale& a) {
  cout << a.nome() << " ";
  const Cane* c =
    dynamic_cast<const Cane*>(&a);
  if(c) c->abbaia();
  if(typeid(a) == typeid(Cane))
    cout << "esattamente-cane ";
}
int main() {
  Cane c; Gatto g; Cucciolo u;
  f(c); cout << "UNO\n";
  f(g); cout << "DUE\n";
  f(u); cout << "TRE\n";
  Animale* p = &u;
  cout << (typeid(p) == typeid(Animale*))
       << (typeid(*p) == typeid(Cucciolo))
       << (dynamic_cast<Gatto*>(p) == nullptr)
       << "\n";
}
```

// =====================================================
// EXTRA 1: crocette (template e override)
// =====================================================
#slide(title: "Extra 1: crocette")[
  #text(size: 0.8em)[
    *1.* Sia `template<class T> class D : public B<T>`, e `m` un campo pubblico di `B<T>`. Nel corpo di un metodo di `D<T>`, l'istruzione `m = 2;`:\
    #opts(
      [compila],
      [non compila],
      [comportamento indefinito],
    )
    \
    *2.* In `B` c'è `virtual void m()`. In `D`, derivata da `B`, si scrive `void m() const {}`. Cos'è?\
    #opts(
      [un metodo che nasconde `B::m`],
      [un override di `B::m`],
      [un errore di compilazione],
    )
  ]
]

#slide(title: "Extra 1: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* Se la base è un template che dipende da `T`, i suoi membri non vengono cercati con il nome semplice: `m = 2` non compila (e se esistesse un `m` globale, verrebbe usato quello). Per raggiungere i membri della base servono `this->m` oppure `B<T>::m`.\ \
    *2 → A.* Per fare override servono stesso nome, stessi parametri *e stesso `const`*. `m() const` è un metodo diverso: nasconde `B::m` ma non lo ridefinisce, quindi con un `B*` verrebbe comunque chiamato `B::m`. Con la parola chiave `override` il compilatore segnalerebbe l'errore.
  ]
]

// =====================================================
// EXTRA 2: crocette (parametri di default, distruttore virtuale)
// =====================================================
#slide(title: "Extra 2: crocette")[
  #text(size: 0.8em)[
    *1.* `B` ha `virtual void m(int x = 0)` e `D` ne fa override con `void m(int x = 5)`. Con `B* p = new D;`, la chiamata `p->m();` esegue `D::m` con `x` uguale a:\
    #opts(
      [5],
      [0],
      [la chiamata è illegale],
    )
    \
    *2.* Perché in una gerarchia polimorfa conviene dichiarare virtuale il distruttore della base `B`?\
    #opts(
      [perché altrimenti non si può derivare da `B`],
      [perché rende più veloce la `delete`],
      [perché elimini tutte le parti proprie],
    )
  ]
]

#slide(title: "Extra 2: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* Il metodo eseguito si sceglie con il tipo *dinamico* (`D::m`), ma il parametro di default viene preso dal tipo *statico* (`B*`): `x = 0`. Stampa quindi il comportamento di `D::m` con il default di `B`.\ \
    *2 → C.* Senza `virtual`, `delete p` con `p` di tipo `B*` invoca solo `~B` (comportamento indefinito): la parte propria di `D` non viene distrutta. Con il distruttore virtuale viene invocato `~D`, e poi `~B`.
  ]
]

// =====================================================
// EXTRA 3: crocette (classi astratte e dynamic_cast)
// =====================================================
#slide(title: "Extra 3: crocette")[
  #text(size: 0.8em)[
    *1.* `A` ha il metodo virtuale puro `virtual void m() =0;` `B` derivata da `A` definisce `m` Quale istruzione è legale?\
    #opts(
      [`A s;`],
      [`A* p = new B;`],
      [dichiarare un riferimento `A&`],
    )
    \
    *2.* `B` è polimorfa e `D` è derivata da `B`. Dopo `B b; B* p = &b;`, `dynamic_cast<D*>(p)` restituisce:\
    #opts(
      [un `D*` valido],
      [lancia un'eccezione `bad_cast`],
      [`nullptr`],
    )
  ]
]

#slide(title: "Extra 3: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* Di una classe astratta non si possono creare oggetti (`S s;` è illegale), ma si possono usare puntatori e riferimenti, anche a oggetti di classi derivate concrete. Sbagliata anche la C: `S&` è legale.\ \
    *2 → C.* L'oggetto puntato da `p` è un `B`, non un `D`: il cast fallisce e restituisce `nullptr`. Con i *riferimenti* (`dynamic_cast<D&>(*p)`) un cast fallito lancia invece `bad_cast`.
  ]
]

// =====================================================
// EXTRA 4: cosa stampa (virtual, default, costruttori)
// =====================================================
#slide(title: "Extra 4: cosa stampa?")[
  #grid(
    columns: (56%, 42%),
    column-gutter: 2%,
    [#code(x1a, size: 0.6em)],
    [#code(x1b, size: 0.65em)],
  )
]

#slide(title: "Extra 4: soluzione")[
  #grid(
    columns: (30%, 66%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        A() A::f1 B() B::f2 UNO
        B::f1 DUE
        A::g B::f1 TRE
        A::h QUATTRO
        B::h(int) CINQUE
        A::f1 SEI
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*, `B b`: prima la base. Dentro `A()` il tipo dinamico è ancora `A`, quindi `f()` chiama `A::f` con il default 1: `A::f1`. Poi `B()`: `f()` chiama `B::f` con il default di `B`: `B::f2`
        - *DUE*, `p->f()`: `f` è virtuale, quindi si esegue `B::f` (tipo dinamico), ma il default si prende dal tipo *statico* `A*`: 1. Stampa `B::f1`
        - *TRE*, `p->g()`: `g` non è virtuale, esegue `A::g`. Dentro, `f()` è chiamata su `this` di tipo `A*`: default 1, e il dispatch virtuale porta a `B::f`: `B::f1`
        - *QUATTRO*, `p->h()`: `B::h(int)` ha parametri diversi, non è un override: `h()` resta `A::h`
        - *CINQUE*, `b.h(3)`: con tipo statico `B` il solo `h` visibile è `h(int)` (`b.h()` sarebbe illegale)
        - *SEI*, `A a = b`: slicing, `a` è un vero `A`; la copia di default non stampa niente. `a.f()` è `A::f1`
      ]
    ],
  )
]

// =====================================================
// EXTRA 5: cosa stampa (template, virtual, distruttori)
// =====================================================
#slide(title: "Extra 5: cosa stampa?")[
  #grid(
    columns: (56%, 42%),
    column-gutter: 2%,
    [#code(x2a, size: 0.6em)],
    [#code(x2b, size: 0.65em)],
  )
]

#slide(title: "Extra 5: soluzione")[
  #grid(
    columns: (34%, 62%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        B3 D UNO
        dinc6 DUE
        dinc12 dinc24 TRE
        B1.5 inc2.5 inc3.5 QUATTRO
        ~D ~B CINQUE
        ~B
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*: `new D<int>(3)` costruisce prima la base `B<int>(3)` (`B3`), poi `D`
        - *DUE*, `p->inc()`: `inc` è virtuale e l'oggetto è un `D<int>`: `x` passa da 3 a 6, stampa `dinc6`. In `D<T>` serve `this->x`, perché `x` è un campo di una base dipendente da `T`
        - *TRE*, `p->due()`: `due` non è virtuale (esegue `B<T>::due`), ma chiama `inc()` su `this`, che è virtuale: due volte `D::inc`, quindi 12 e 24
        - *QUATTRO*: `B<double>` è un'altra istanza, senza `D`: `B1.5`, e `due()` usa `B::inc`: 2.5 e 3.5
        - *CINQUE*, `delete p`: il distruttore è virtuale, quindi `~D` e poi `~B`. Senza `virtual` solo `~B`: comportamento indefinito
        - Ultima riga: alla fine del `main` si distrugge `b`, un `B<double>`: `~B`
      ]
    ],
  )
]

// =====================================================
// EXTRA 6: cosa stampa (classe astratta, dynamic_cast, typeid)
// =====================================================
#slide(title: "Extra 6: cosa stampa?")[
  #grid(
    columns: (46%, 52%),
    column-gutter: 2%,
    [#code(x3a, size: 0.6em)],
    [#code(x3b, size: 0.55em)],
  )
]

#slide(title: "Extra 6: soluzione")[
  #grid(
    columns: (34%, 62%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        cane bau esattamente-cane UNO
        gatto DUE
        cucciolo bau TRE
        111
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - `Animale` è astratta: non ha oggetti propri, ma `f` lavora su riferimenti a oggetti delle derivate
        - *UNO*, `f(c)`: `nome()` è virtuale: `cane`. Il `dynamic_cast` a `const Cane*` ha successo (l'oggetto è un `Cane`): `bau`. `typeid(a)` è esattamente `Cane`: `esattamente-cane`
        - *DUE*, `f(g)`: `gatto`. Il cast a `Cane*` fallisce (`nullptr`): niente `bau`. `typeid(a)` è `Gatto`: niente `esattamente-cane`
        - *TRE*, `f(u)`: `cucciolo`. Il cast a `Cane*` ha successo, perché un `Cucciolo` è anche un `Cane`: `bau`. Ma il tipo dinamico è `Cucciolo`, non `Cane`: niente `esattamente-cane`
        - Riga `111`: `typeid(p)` è il tipo statico `Animale*` (puntatore non dereferenziato): 1. `typeid(*p)` è il tipo dinamico `Cucciolo` (classe polimorfa): 1. Il cast a `Gatto*` fallisce: `nullptr`, quindi 1
      ]
    ],
  )
]
