#import "@preview/polylux:0.4.0": *
#import "./../unipd.typ": *
#show: unipd-theme.with(palette: (..unipd-palette, font: "Noto Sans"))

#title-slide(
  authors: "Matteo Mazzaretto",
  title: "Tutorato 5 - Esercizi Extra",
  date: "17 novembre 2026",
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

// Cosa stampa 1: ordine di costruzione (base, campi, corpo)
#let x1a = ```cpp
class Z {
  public:
    Z() {cout << "Z0 ";}
    Z(int x) {cout << "Z" << x << " ";}
};
class B {
  private:
    Z a; Z b;
  public:
    B(): b(1) {cout << "B0 ";}
    B(int n): b(n), a(n+1) {cout << "B1 ";}
};
```

#let x1b = ```cpp
class D: public B {
  private:
    Z z; B m;
  public:
    D(): m(5) {cout << "D0 ";}
    D(int n): z(n), B(n) {cout << "D1 ";}
};
int main() {
  D d; cout << "UNO\n";
  D e(2); cout << "DUE\n";
}
```

// Cosa stampa 2: costruttore di copia (con e senza B(d))
#let x2a = ```cpp
class Z {
  public:
    Z() {cout << "Z0 ";}
    Z(const Z& z) {cout << "Zc ";}
};
class B {
  private:
    Z w;
  public:
    B() {cout << "B0 ";}
    B(const B& b) {cout << "Bc ";}
};
class D1: public B {
  private:
    Z z;
  public:
    D1() {cout << "D10 ";}
    D1(const D1& d) {cout << "D1c ";}
};
```

#let x2b = ```cpp
class D2: public B {
  private:
    Z z;
  public:
    D2() {cout << "D20 ";}
    D2(const D2& d): B(d), z(d.z)
      {cout << "D2c ";}
};
void f(D2 d) {cout << "f ";}
int main() {
  D1 a; cout << "UNO\n";
  D1 b = a; cout << "DUE\n";
  D2 c; cout << "TRE\n";
  D2 d = c; cout << "QUATTRO\n";
  f(c); cout << "CINQUE\n";
  B e = c; cout << "SEI\n";
}
```

// Cosa stampa 3: assegnazione e distruttori
#let x3a = ```cpp
class Z {
public:
  Z() {cout << "Z0 ";}
  Z& operator=(const Z& z)
    {cout << "Z= "; return *this;}
  ~Z() {cout << "~Z ";}
};
class C {
  private:
    Z w;
  public:
    C() {cout << "C0 ";}
    C& operator=(const C& c)
      {w = c.w; cout << "C= "; return *this;}
    ~C() {cout << "~C ";}
};
class D1: public C {
  private:
    Z z;
  public:
    D1() {cout << "D10 ";}
    D1& operator=(const D1& d)
      {z = d.z; cout << "D1= "; return *this;}
    ~D1() {cout << "~D1 ";}
};
```

#let x3b = ```cpp
class D2: public C {
  private:
    Z z;
  public:
    D2() {cout << "D20 ";}
    D2& operator=(const D2& d)
      {C::operator=(d); z = d.z;
      cout << "D2= "; return *this;}
    ~D2() {cout << "~D2 ";}
};
int main() {
  D1 a, b; cout << "UNO\n";
  a = b; cout << "DUE\n";
  { D2 c, d; c = d; } cout << "TRE\n";
  C x; x = a; cout << "QUATTRO\n";
}
```

// Cosa stampa 4: passaggio per valore, per riferimento, slicing
#let x4a = ```cpp
class B {
  public:
    B() {cout << "B0 ";}
    B(const B& b) {cout << "Bc ";}
    ~B() {cout << "~B ";}
};
class D: public B {
  public:
    D() {cout << "D0 ";}
    D(const D& d): B(d) {cout << "Dc ";}
    ~D() {cout << "~D ";}
};
void f(B b) {cout << "f ";}
void g(B& b) {cout << "g ";}
void h(D d) {cout << "h ";}
B k(D& d) {cout << "k "; return d;}
```

#let x4b = ```cpp
int main() {
  D d; cout << "UNO\n";
  f(d); cout << "DUE\n";
  g(d); cout << "TRE\n";
  h(d); cout << "QUATTRO\n";
  k(d); cout << "CINQUE\n";
}
```

// Cosa stampa 5: ridefinizione, scoping, tipo statico, slicing
#let x5a = ```cpp
class A {
  protected:
    int v;
  public:
    A(int x = 1): v(x) {cout << "A" << v << " ";}
    void inc() {v += 1;}
    void stampa() const {cout << "a" << v << " ";}
};
class B: public A {
  public:
    B(): A(5) {cout << "B ";}
    void inc() {A::inc(); v *= 2;}
    void stampa() const
      {A::stampa(); cout << "b" << v << " ";}
};
```

#let x5b = ```cpp
class C: public B {
  public:
    int v;
    C(): v(0) {cout << "C ";}
    void inc() {B::inc(); v++;}
    void stampa() const
      {B::stampa(); cout << "c" << v << " ";}
};
int main() {
  C c; cout << "UNO\n";
  c.inc(); c.stampa(); cout << "DUE\n";
  B* pb = &c;
  pb->inc(); pb->stampa(); cout << "TRE\n";
  A a = c;
  a.inc(); a.stampa(); cout << "QUATTRO\n";
}
```

// =====================================================
// EXTRA 1: crocette (conversioni e tipo statico)
// =====================================================
#slide(title: "Extra 1: crocette")[
  #text(size: 0.8em)[
    *1.* Siano `D d; B b;` con `D` derivata *pubblicamente* da `B`. Quale riga è legale?\
    #opts(
      [`d = b;`],
      [`b = d;`],
      [nessuna delle due],
    )
    \
    *2.* Sia `B* pb = &d;` con `d` di tipo `D`. Il metodo `f()` è ridefinito in `D`. Cosa chiama `pb->f()`?\
    #opts(
      [`D::f`, perché `pb` punta a un oggetto `D`],
      [`B::f`, perché conta il tipo statico `B*`],
      [è illegale],
    )
  ]
]

#slide(title: "Extra 1: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* `b = d` è legale: nel `B` si copia solo il sottooggetto di tipo `B`, le informazioni di `D` si perdono (*slicing*). `d = b` è illegale: da `B` a `D` non c'è conversione, mancherebbero i campi propri di `D`.\ \
    *2 → B.* La scelta del metodo viene fatta dal compilatore sul tipo *statico* del puntatore, che per lui è l'unico che esiste. Quindi `pb->f()` chiama `B::f`, anche se `pb` punta a un oggetto `D`.
  ]
]

// =====================================================
// EXTRA 2: crocette (accessibilità)
// =====================================================
#slide(title: "Extra 2: crocette")[
  #text(size: 0.8em)[
    *1.* Sia `class D : protected B`. Un membro *pubblico* di `B` in `D` è:\
    #opts(
      [pubblico],
      [protetto],
      [privato],
    )
    \
    *2.* La classe `F` è amica di `B`, e `D` è derivata da `B`. `F` è amica anche di `D`?\
    #opts(
      [sì, l'amicizia si eredita],
      [no, l'amicizia non si eredita],
      [sì, ma solo con la derivazione pubblica],
    )
  ]
]

#slide(title: "Extra 2: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* Con la derivazione protetta i membri pubblici e protetti della base diventano *protetti* nella derivata. Con quella pubblica restano come sono, con quella privata diventano privati.\ \
    *2 → B.* Le classi amiche non vengono ereditate: l'amicizia concessa da `B` vale per `B`, non per le sue derivate. Se `F` deve accedere ai membri di `D`, `D` deve dichiararla amica.
  ]
]

// =====================================================
// EXTRA 3: crocette (costruttori e distruttori)
// =====================================================
#slide(title: "Extra 3: crocette")[
  #text(size: 0.8em)[
    *1.* `D` deriva da `B`, che ha un costruttore di copia. In `D(const D& d): z(d.z) {}` la lista non nomina `B`. Cosa viene invocato per il sottooggetto `B`?\
    #opts(
      [il costruttore di copia di `B`],
      [il costruttore di default di `B`],
      [nessuno: la parte `B` non viene costruita],
    )
    \
    *2.* Viene distrutto un oggetto `D`, derivato da `B` e con un campo `Z z`. In che ordine vengono invocati i distruttori?\
    #opts(
      [`~B`, `~Z`, `~D`],
      [`~D`, `~Z`, `~B`],
      [`~D`, `~B`, `~Z`],
    )
  ]
]

#slide(title: "Extra 3: soluzione")[
  #text(size: 0.85em)[
    *1 → B.* Il sottooggetto `B` si costruisce sempre: se la lista non lo nomina, viene invocato il costruttore di *default*, e la parte base *non viene copiata*. Va scritto `B(d)` nella lista. Se `B` non avesse un costruttore di default, sarebbe un errore.\ \
    *2 → B.* L'ordine di distruzione è inverso a quello di costruzione: prima il corpo di `~D`, poi i campi propri di `D` (`~Z`), infine la base (`~B`).
  ]
]

// =====================================================
// EXTRA 4: cosa stampa (ordine di costruzione)
// =====================================================
#slide(title: "Extra 4: cosa stampa?")[
  #grid(
    columns: (58%, 40%),
    column-gutter: 2%,
    [#code(x1a, size: 0.6em)],
    [#code(x1b, size: 0.6em)],
  )
]

#slide(title: "Extra 4: soluzione")[
  #grid(
    columns: (38%, 58%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        Z0 Z1 B0 Z0 Z6 Z5 B1 D0 UNO
        Z3 Z2 B1 Z2 Z0 Z1 B0 D1 DUE
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*, `D d`: `D()` non nomina la base, quindi parte `B()`. I campi di `B` si costruiscono nell'ordine di *dichiarazione* (`a`, poi `b`) e non della lista: `Z0`, `Z1`, poi `B0`
        - Poi i campi di `D` nell'ordine di dichiarazione: `z` (`Z0`) e `m(5)`. `B(int)` costruisce `a(6)` e poi `b(5)`: `Z6 Z5`, poi `B1`. Infine `D0`
        - *DUE*, `D e(2)`: anche se la lista scrive `z(n), B(n)`, la base si costruisce *sempre prima*: `B(2)` dà `Z3 Z2 B1`
        - Poi `z(2)`: `Z2`; `m` non è in lista e usa `B()`: `Z0 Z1 B0`. Infine `D1`
      ]
    ],
  )
]

// =====================================================
// EXTRA 5: cosa stampa (costruttore di copia)
// =====================================================
#slide(title: "Extra 5: cosa stampa?")[
  #grid(
    columns: (50%, 48%),
    column-gutter: 2%,
    [#code(x2a, size: 0.6em)],
    [#code(x2b, size: 0.6em)],
  )
]

#slide(title: "Extra 5: soluzione")[
  #grid(
    columns: (30%, 66%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        Z0 B0 Z0 D10 UNO
        Z0 B0 Z0 D1c DUE
        Z0 B0 Z0 D20 TRE
        Z0 Bc Zc D2c QUATTRO
        Z0 Bc Zc D2c f CINQUE
        Z0 Bc SEI
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*, `D1 a`: base `B()` (`Z0 B0`), campo `z` (`Z0`), `D10`
        - *DUE*, `D1 b = a`: `D1(const D1&)` non nomina la base: parte `B()` di *default* (`Z0 B0`), la parte base non viene copiata. `z` non è in lista: default `Z0`. Poi `D1c`
        - *TRE*, `D2 c`: come `UNO`, con `D20`
        - *QUATTRO*, `D2 d = c`: `B(d)` invoca il costruttore di copia di `B`. Il campo `w` di `B` non è nella sua lista: default `Z0`, poi `Bc`. Poi `z(d.z)` copia: `Zc`. Infine `D2c`
        - *CINQUE*, `f(c)`: il parametro per valore si copia come in `QUATTRO`, poi si stampa `f`
        - *SEI*, `B e = c`: *slicing*, si invoca solo `B(const B&)`: `Z0 Bc`. I costruttori di `D2` non vengono toccati
      ]
    ],
  )
]

// =====================================================
// EXTRA 6: cosa stampa (assegnazione e distruttori)
// =====================================================
#slide(title: "Extra 6: cosa stampa?")[
  #grid(
    columns: (50%, 48%),
    column-gutter: 2%,
    [#code(x3a, size: 0.5em)],
    [#code(x3b, size: 0.5em)],
  )
]

#slide(title: "Extra 6: soluzione")[
  #code(size: 0.5em)[
    ```text
    Z0 C0 Z0 D10 Z0 C0 Z0 D10 UNO
    Z= D1= DUE
    Z0 C0 Z0 D20 Z0 C0 Z0 D20 Z= C= Z= D2= ~D2 ~Z ~C ~Z ~D2 ~Z ~C ~Z TRE
    Z0 C0 Z= C= QUATTRO
    ~C ~Z ~D1 ~Z ~C ~Z ~D1 ~Z ~C ~Z
    ```
  ]
  #text(size: 0.7em)[
    - *UNO*: costruzione di `a` e di `b`. Per ciascuno, la base `C` (campo `w`: `Z0`, poi `C0`), poi `z` (`Z0`) e `D10`
    - *DUE*, `a = b`: `D1::operator=` assegna solo `z` (`Z=`) e stampa `D1=`. `C::operator=` non viene chiamato, quindi `w` della base *non viene assegnato*: non compaiono `Z= C=`
    - *TRE*, `c = d`: `C::operator=(d)` assegna `w` (`Z=`) e stampa `C=`; poi `z` (`Z=`) e `D2=`. A fine blocco si distruggono `d` e poi `c`; per ciascuno: `~D2`, il campo `z` (`~Z`), la base (`~C`, poi il suo campo `w`: `~Z`)
    - *QUATTRO*, `x = a`: `a` viene convertito a `const C&` (*slicing*): `C::operator=` dà `Z= C=`
    - Ultima riga, fine del `main`: si distruggono `x`, poi `b`, poi `a` (ordine inverso): `~C ~Z`, `~D1 ~Z ~C ~Z`, `~D1 ~Z ~C ~Z`
  ]
]

// =====================================================
// EXTRA 7: cosa stampa (valore, riferimento, slicing)
// =====================================================
#slide(title: "Extra 7: cosa stampa?")[
  #grid(
    columns: (62%, 36%),
    column-gutter: 2%,
    [#code(x4a, size: 0.6em)],
    [#code(x4b, size: 0.65em)],
  )
]

#slide(title: "Extra 7: soluzione")[
  #grid(
    columns: (30%, 66%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        B0 D0 UNO
        Bc f ~B DUE
        g TRE
        Bc Dc h ~D ~B QUATTRO
        k Bc ~B CINQUE
        ~D ~B
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*: costruzione di `d`: `B0 D0`
        - *DUE*, `f(d)`: il parametro è un `B` per valore, quindi si copia la sola parte `B` di `d` (*slicing*): `Bc`. Poi `f`. All'uscita il parametro si distrugge, ed è un `B`: `~B` (non `~D`)
        - *TRE*, `g(d)`: passaggio per riferimento, nessuna copia: solo `g`
        - *QUATTRO*, `h(d)`: il parametro è un `D` per valore: `D(const D&)` invoca `B(d)` (`Bc`), poi `Dc`. Poi `h`, e all'uscita `~D ~B`
        - *CINQUE*, `k(d)`: `return d` converte il `D&` in un `B` per copia: `Bc` (slicing). Il temporaneo restituito viene distrutto a fine istruzione: `~B`
        - Ultima riga, fine del `main`: si distrugge `d`: `~D ~B`
      ]
    ],
  )
]

// =====================================================
// EXTRA 8: cosa stampa (ridefinizione, scoping, tipo statico)
// =====================================================
#slide(title: "Extra 8: cosa stampa?")[
  #grid(
    columns: (50%, 48%),
    column-gutter: 2%,
    [#code(x5a, size: 0.6em)],
    [#code(x5b, size: 0.6em)],
  )
]

#slide(title: "Extra 8: soluzione")[
  #grid(
    columns: (30%, 66%),
    column-gutter: 4%,
    [
      *Output:*
      #code(size: 0.6em)[
        ```text
        A5 B C UNO
        a12 b12 c1 DUE
        a26 b26 TRE
        a27 QUATTRO
        ```
      ]
    ],
    [
      #text(size: 0.75em)[
        - *UNO*, `C c`: `C()` non nomina la base, quindi `B()`; a sua volta `B()` invoca `A(5)`. Ordine: `A5`, `B`, `C`
        - *DUE*, `c.inc()`: `C::inc` chiama `B::inc`, che chiama `A::inc`: `A::v` diventa 6, poi `v *= 2` dà 12. Infine `v++` incrementa `C::v`, che è un campo *diverso* (nasconde `A::v`): vale 1
        - `c.stampa()` percorre `C`, `B`, `A` con lo scoping: stampa `a12`, poi `b12`, poi `c1`
        - *TRE*, `pb->inc()`: il tipo statico è `B*`, quindi si chiama `B::inc` e non `C::inc`: `A::v` va a 13 e poi 26, `C::v` resta 1. `pb->stampa()` è `B::stampa`: `a26 b26`, senza `c`
        - *QUATTRO*, `A a = c`: *slicing*, si copia solo la parte `A` (`A::v = 26`), e il costruttore di copia di default non stampa. `a.inc()` dà 27 e `a.stampa()` stampa `a27`
      ]
    ],
  )
]
