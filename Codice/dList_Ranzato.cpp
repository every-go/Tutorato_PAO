/*
ESERCIZIO. 

Definire un template di classe dList<T> i cui oggetti rappresentano una struttura dati lista doppiamente concatenata (doubly linked list) per elementi di uno stesso tipo T. Il template dList<T> deve soddisfare i seguenti vincoli:

1. Gestione della memoria senza condivisione.

2. dList<T> rende disponibile un costruttore dList(unsigned int k, const T& t) che costruisce una 
lista contenente k nodi ed ognuno di questi nodi memorizza una copia di t.

3. dList<T> permette l’inserimento in testa ed in coda ad una lista in tempo O(1) (cioe` costante):
-- Deve essere disponibile un metodo void insertFront(const T&) con il seguente comportamento: dl.insertFront(t) inserisce l’elemento t in testa a dl in tempo O(1).
-- Deve essere disponibile un metodo void insertBack(const T&) con il seguente comportamento: dl.insertBack(t) inserisce l’elemento t in coda a dl in tempo O(1).

4. dList<T> rende disponibile un opportuno overloading di operator< che implementa l’ordinamento lessicografico (ad esempio, si ricorda che per l'ordinamento lessicografico tra stringhe abbiamo che "campana" < "cavolo" e che "buono" < "ottimo").

5. dList<T> rende disponibile un tipo iteratore costante dList<T>::const_iterator i cui oggetti permettono di iterare sugli elementi di una lista.
*/


template<class T>
class dList {
private:
  class nodo {
  public:
    T info;
    nodo* prev;
    nodo* next;
    nodo(const T& t = T(), nodo* p =0, nodo* n =0): info(t), prev(p), next(n) {} 
  };
  nodo* first; // primo nodo
  nodo* last;  // ultimo nodo
  // lista vuota IFF first == nullptr && last == nullptr

  static void copia(nodo* primo, nodo*& f, nodo*& l) {
    if(primo == nullptr) {f=l=nullptr; return;}
    // primo != nullptr
    copia(primo->next,f,l);
    f = new nodo(primo->info,nullptr,f);
    if(f->next == nullptr) // la lista puntata da primo aveva un solo nodo
      {
	l = f;
      }
    else // la lista puntata da primo aveva piu' di un nodo, quindi first-next != nullptr
      (f->next)->prev = f;
  }
  
  static void distruggi(nodo* primo) {
    if(primo != nullptr) {
      distruggi(primo->next);
      delete primo;
    }
  }

  static bool rec_lex_ord(nodo* f1, nodo* f2) {
    if(!f1 && !f2) return false;   // entrambe vuote: uguali
    if(!f2) return false;          // f2 vuota, f1 no: f2 < f1
    if(!f1) return true;           // f1 vuota, f2 no: f1 < f2
    // f1 e f2 non vuote
    if(f1->info < f2->info) return true;
    if(f2->info < f1->info) return false;
    // attenzione: non necessariamente f1->info == f2->info
    if(f1->info == f2->info) return rec_lex_ord(f1->next, f2->next);
    return false;
  }
  
public:
  class const_iterator {
    friend class dList;
  private:
    const nodo* ptr; // FONDAMENTALE perche' e' un const_iterator
    bool pte;
    // iteratore indefinito IFF ptr == 0 && !pte
    // iteratore definito IFF ptr != 0
    // iteratore definito e non past-the-end IFF ptr!=0 & !pte
    // iteratore definito e past-the-end: IFF ptr == last+1 & pte

    const_iterator(nodo* p = nullptr, bool e = false): ptr(p), pte(e) {}
  public:
    const_iterator& operator++() {
      if(ptr)
	// ptr != nullptr
	if(!pte) {  // non siamo a past-the-end
	  if(ptr->next == nullptr) // ci riferiamo all'ultimo nodo della lista
	    {++ptr; pte=true;}
	  else // ci riferiamo ad un nodo della lista che non e' l'ultimo
	    ptr = ptr->next;
	}
      return *this;
    }
    
    const_iterator operator++(int) {
      const_iterator aux(*this);
      ++(*this);
      return aux;
    }
    
    const_iterator& operator--() {
      if(ptr) {
	// ptr != nullptr
	if(pte)
	  {--ptr; pte= false;}
	else // iteratore definito e non past-the-end
	  ptr = ptr->prev;
      }
      return *this;
    }
    
    const_iterator operator--(int) {
      const_iterator aux(*this);
      --(*this);
      return aux;
    }
    
    const T& operator*() const {
      if(pte) {const T* p = nullptr; return *p;} // to check
      return ptr->info;
    }
    
    const T* operator->() const {
      if(pte) return nullptr; 
      return &(ptr->info);
    }

    bool operator==(const const_iterator& cit) const {
      return ptr == cit.ptr && pte == cit.pte;
    }
    
    bool operator!=(const const_iterator& cit) const {
      return !(*this == cit);
    }
    
  };

  const_iterator begin() const {
    if(!first) return const_iterator();
    // lista non vuota
    return const_iterator(first);
  }
		       
  const_iterator end() const {
    if(!first) return const_iterator();
    // lista non vuota
    return const_iterator(last+1,true);
  }
  
  void insertFront(const T& t) {
    first = new nodo(t,nullptr,first);
    if(first->next == nullptr) last=first;
    else // lista non vuota
      (first->next)->prev = first;
  }

  void insertBack(const T& t) {
    last = new nodo(t,last,nullptr);
    if(last->prev == nullptr) first=last;
    else // lista non vuota
      (last->prev)->next = last;
  }

  dList(const dList& d): first(nullptr), last(nullptr) {
    copia(d.first, first, last);
  }
  
  dList& operator=(const dList& d) {
    if(this != &d) {
      nodo *f, *l;
      copia(d.first, f, l);
      distruggi(first);
      first = f; last = l;
    }
    return *this;
  }
  
  ~dList() {distruggi(first);}
  
  // costruttore a 0-1-2 parametri
  dList(unsigned int k =0, const T& t =T()): first(nullptr), last(nullptr) {
    for(unsigned int i=0; i<k; ++i) insertFront(t);
  }
  
  bool operator<(const dList& d) const {
    return rec_lex_ord(first,d.first);
  }  
};

#include<iostream>

template<class T>
std::ostream& operator<<(std::ostream& os, const dList<T>& d) {
  for(auto cit = d.begin(); cit != d.end(); ++cit)
    os << *cit << " ";
  return os;
}

struct Punto { int x, y; };   // da mettere prima del main

// esempio d'uso
int main() {
  dList<int> x(4,2), y(0,0), z(6,8);
  std::cout << "x= " << x << std::endl;
  std::cout << "y= " << y << std::endl;
  std::cout << "z= " << z << std::endl;
  if(x<y) std::cout << "x < y" << std::endl;
  if(z<x) std::cout << "z < x" << std::endl;
  if(y<z) std::cout << "y < z" << std::endl;
  if(z<y) std::cout << "z < y" << std::endl;
  y=x;
  x.insertFront(-2); z.insertFront(3); y.insertFront(0); y.insertBack(-2); 
  std::cout << "x= " << x << std::endl;
  std::cout << "y= " << y << std::endl;
  std::cout << "z= " << z << std::endl;

  if(x<y) std::cout << "x < y" << std::endl;
  if(z<x) std::cout << "z < x" << std::endl;
  if(y<z) std::cout << "y < z" << std::endl;
  if(z<y) std::cout << "z < y" << std::endl;

  dList<int>::const_iterator it = x.begin();
  std::cout << "primo di x: " << *it << std::endl;
  ++it;
  std::cout << "secondo di x + 1: " << *it + 1 << std::endl;

  const int& r = *it;                       // riferimento all'elemento, nessuna copia
  std::cout << "r = " << r << std::endl;

  int somma = 0;
  for(dList<int>::const_iterator cit = y.begin(); cit != y.end(); ++cit)
    somma += *cit;
  std::cout << "somma di y = " << somma << std::endl;

  dList<int>::const_iterator ult = y.end();
  --ult;                                    // da end() si torna sull'ultimo elemento
  std::cout << "ultimo di y: " << *ult << std::endl;

  // *it = 5;                               // ERRORE: const_iterator, l'elemento è const

  // ---------- uso di -> (accesso a un membro dell'elemento) ----------
  dList<std::string> s;
  s.insertBack("campana"); s.insertBack("cavolo"); s.insertBack("ok");
  for(dList<std::string>::const_iterator cit = s.begin(); cit != s.end(); ++cit)
    std::cout << *cit << " ha " << cit->size() << " lettere" << std::endl;

  Punto a = {1, 2}, b = {3, 4};
  dList<Punto> p;
  p.insertBack(a); p.insertBack(b);
  for(dList<Punto>::const_iterator cit = p.begin(); cit != p.end(); ++cit)
    std::cout << "(" << cit->x << ", " << cit->y << ") ";
  std::cout << std::endl;

  dList<Punto>::const_iterator pit = p.begin();
  std::cout << pit->x << " " << (*pit).x << std::endl;   // sono la stessa cosa

  // pit->x = 9;                            // ERRORE: const_iterator
  // x.begin()->size();                     // ERRORE: int non ha membri, qui serve *
}
