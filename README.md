# ASM_BinaryLegends
Proiect seminar ASC 
Documentație proiect ASM

Echipa: Binary Legends(Guzu Naomi, Filip Maria, Duciuc Georgiana)
Student 1: Citirea datelor, conversia din hex și gestionarea șirului în memorie
Student 2: Operațiile pe biți, calculul cuvântului C și rotirile
Student 3: Sortarea, afișarea rezultatelor, documentația și diagrama bloc
https://github.com/guzunaomi2005-a11y/ASM_BinaryLegends

Proiectul are ca scop implementarea unui program în limbaj de asamblare pentru procesorul Intel 8086 (mod 16-biți), utilizând mediul TASM/TLINK. Obiectivul principal este procesarea unui șir de date (8-16 octeți) prin operații aritmetice, manipulări la nivel de bit, sortare și afișare interactivă.

Etape de procesare:
1.	Citirea și validarea: Primul pas este preluarea datelor de la utilizator. Deoarece lucrăm în mediul DOS, folosim o funcție specială (0Ah) care „ascultă” ce scrie utilizatorul.
	Conversia: Calculatorul primește text (litere și cifre), dar noi avem nevoie de numere. Am creat o logică prin care transformăm, de exemplu, caracterul 'A' în valoarea numerică 10 (Ah).
	Verificarea: Programul este „atent” să nu primească prea puține sau prea multe date. Dacă introduci mai puțin de 8 sau mai mult de 16 valori, programul îți spune că ai greșit și te pune să mai încerci o dată.
2.	Calculul cuvântului C: 
•  Pasul 1 (XOR): Ne uităm la prima cifră hexazecimală a primului număr și la ultima cifră a ultimului număr. Facem o operație logică numită XOR între ele. Rezultatul ocupă primii 4 biți ai lui C
• Pasul 2 (OR): Luăm bucățica din mijloc (biții 2-5) a fiecărui număr din șir și le „adunăm” logic (operația OR). Dacă un bit a fost „1” undeva în șir, va fi „1” și în rezultat. Aceasta ocupă biții 4-7 ai lui C.
•  Pasul 3 (Suma): Adunăm pur și simplu toate numerele din șir. Dacă suma depășește 255, o luăm de la capăt (asta înseamnă modulo 256). Rezultatul ocupă restul de biți (8-15) ai lui C.


3.	Sortarea: Pentru a organiza datele, am folosit metoda Bubble Sort. Este ca și cum am trece prin șir de mai multe ori și, de fiecare dată când vedem două numere vecine care nu sunt în ordinea corectă (cel mic înaintea celui mare), le schimbăm locul între ele folosind instrucțiunea XCHG. La final, cel mai mare număr ajunge primul.
4.	Identificarea octetului special: Programul analizează fiecare octet sortat, numărând biții de 1 prin shiftări succesive. Dacă numărul de biți este > 3, se reține poziția maximului.
5.	Rotiri și afișare: Fiecare octet suferă o rotire circulară la stânga cu N poziții (unde N este suma primilor 2 biți). Rezultatele sunt afișate în format Hexazecimal și Binar.
6.	Pentru a asigura o colaborare eficientă, am utilizat următoarele bune practici:
•	Branch-uri dedicate: Fiecare student a lucrat pe o ramură separată 
•	Pull Requests (PR): Integrarea codului în ramura principală (main) s-a făcut prin Pull Requests, permițând colegilor să revizuiască codul înainte de "Merge".
•	Comentarii: Codul este documentat direct în sursă pentru a explica rolul fiecărui registru și fluxul de execuție.

Dificultăți întâmpinate:
1.	O dificultate majoră a reprezentat-o conversia valorilor din binar în caractere ASCII pentru afișare, deoarece a trebuit să implementăm manual logica de transformare a cifrelor hexazecimale A-F.
2.	Gestionarea corectă a flag-urilor (Carry Flag) în timpul operațiilor de shiftare pentru numărarea biților a necesitat o atenție sporită la registrul de stare.
3.	Sincronizarea lucrului în echipă pe GitHub a impus o rigoare în utilizarea branch-urilor pentru a evita conflictele în fișierul sursă principal, deoarece a fost pentru prima oară când am lucrat în acest fel.
4.	Protejarea registrelor: În timpul buclelor de rotație, registrul CL era necesar atât pentru contorul buclei, cât și pentru valoarea rotației. Soluția a fost utilizarea stivei pentru a păstra integritatea contorului.
5.	Sincronizarea tipurilor de date: Inițial, nr_octeti a fost definit ca DW (16 biți), apoi schimbat în DB (8 biți). Am rezolvat acest lucru prin utilizarea XOR AH, AH înainte de a muta valoarea în registre de index (SI).
6.	Suma tuturor octeților putea depăși valoarea de 255 (FFh), riscând să corupă alți biți din registrul de 16 biți. Ca soluție, am efectuat adunarea direct în registrul de 8 biți al. Aceasta realizează automat operația modulo 256, deoarece orice transport (carry) peste bitul 7 este ignorat de registru, păstrând doar restul cerut de specificațiile proiectului.
7.	La începutul colaborării, am întâmpinat eroarea 403 Forbidden la încercarea de a da push codului pe repository-ul central, deși branch-urile erau create corect. Problema a fost identificată ca fiind legată de drepturile de acces ale colaboratorilor. Proprietarul repository-ului a trebuit să ne adauge manual in echipă în secțiunea "Settings -> Collaborators", iar apoi a trebuit să acceptăm invitația primită prin e-mail.
8.	Variabila nr_octeti a fost definită ca DB (8 biți), însă registrele de index (precum SI sau DI) și registrul numărător CX necesită valori pe 16 biți. Mutarea directă (MOV SI, nr_octeti) genera erori de asamblare ("Operand types do not match").  Am implementat o metodă de extensie prin zero a valorii. Am încărcat valoarea în AL, am curățat registrul AH folosind XOR AH, AH, obținând astfel în AX valoarea corectă pe 16 biți, care a putut fi mutată apoi în SI sau CX.


 


