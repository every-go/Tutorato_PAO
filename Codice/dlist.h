#ifndef DLIST_H
#define DLIST_H

/*
ESERCIZIO. 

Definire un template di classe dList<T> i cui oggetti rappresentano una struttura dati lista doppiamente concatenata (doubly linked list) per elementi di uno stesso tipo T. Il template dList<T> deve soddisfare i seguenti vincoli:

1. Gestione della memoria senza condivisione.

2. dList<T> rende disponibile un costruttore dList(unsigned int k, const T& t) che costruisce una lista contenente k nodi ed ognuno di questi nodi memorizza una copia di t.

3. dList<T> permette l’inserimento in testa ed in coda ad una lista in tempo O(1) (cioe` costante):
-- Deve essere disponibile un metodo void insertFront(const T&) con il seguente comportamento: dl.insertFront(t) inserisce l’elemento t in testa a dl in tempo O(1).
-- Deve essere disponibile un metodo void insertBack(const T&) con il seguente comportamento: dl.insertBack(t) inserisce l’elemento t in coda a dl in tempo O(1).

4. dList<T> rende disponibile un opportuno overloading di operator< che implementa l’ordinamento lessicografico (ad esempio, si ricorda che per l'ordinamento lessicografico tra stringhe abbiamo che "campana" < "campione" e che "buono" < "ottimo").

5. dList<T> rende disponibile un opportuno tipo iteratore costante dList<T>::const_iterator i cui oggetti permettono di iterare sugli elementi di una lista. Deve essere disponibile l'iteratore past-the-end. 
*/

/*
NB ho aggiunto i metodi printList(), printList_backward() e is_valid() per far funzionare correttamente delle funzioni nel main seppur non siano richieste nella consegna, inoltre ho aggiunto delle piccolissime eccezioni
*/

template<class T>
class dList{
   private:
      class nodo{
         friend class dList<T>;
         private:
            nodo* next;
            nodo* prec;
            T info;
         public:
            nodo(const T&, nodo* = nullptr, nodo* = nullptr);
      };
      //elementi
      nodo* first;
      nodo* last;
      //metodi statici
      static void distruggi(nodo*);
      static void copia(nodo*, nodo*&, nodo*&);
      static bool min(nodo*, nodo*);
   public:
      dList();
      dList(unsigned int, const T&);
      //big 3
      ~dList();
      dList(const dList&);
      dList& operator=(const dList&);
      //metodi
      void insertFront(const T&);
      void insertBack(const T&);
      bool operator<(const dList&) const;
      bool operator<=(const dList&) const;
      void printList() const;
      void printList_backward() const;
      //iteratore
      class const_iterator{
         friend class dList<T>;
         private:
            //metto const per indicare che non si può modificare valore puntato
            const dList::nodo* iter;
            bool past_the_end;
         public:
            const_iterator(const dList::nodo* = nullptr, bool = false);
            bool operator==(const const_iterator&) const;
            bool operator!=(const const_iterator&) const;
            const_iterator& operator++();    //prefisso
            const_iterator operator++(int);  //postfisso
            const_iterator& operator--();    //prefisso
            const_iterator operator--(int);  //postfisso
            bool is_valid() const;
            const T* operator->() const;
            const T& operator* () const;
      };
      const_iterator begin() const;
      const_iterator end() const;
};

#endif