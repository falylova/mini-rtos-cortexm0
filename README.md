# Mini-RTOS — ARM Cortex-M0

Implémentation d'un mini système d'exploitation temps réel (RTOS) sur ARM Cortex-M0, exécuté en simulation avec **Keil MDK**.

Projet universitaire — Matière : Microprocesseur II  
Niveau : M2 — ESPA, Université d'Antananarivo  
Année : 2025-2026

---

## Description

Ce projet implémente un mini-RTOS capable de faire tourner **3 tâches en pseudo-parallélisme** sur un processeur ARM Cortex-M0. Le système alterne entre les tâches toutes les millisecondes grâce à un ordonnancement **Round-Robin** déclenché par le timer **SysTick**. Le changement de contexte est entièrement écrit en **assembleur ARM** via le gestionnaire PendSV.

---

## Structure du projet

```
mini-rtos-cortexm0/
│
├── main.c               # Point d'entrée — initialisation et lancement
├── scheduler.h          # Définitions partagées (TCB, constantes, prototypes)
├── scheduler.c          # Création des tâches, SysTick, Round-Robin
├── tasks.c              # Les trois tâches applicatives (Task1, Task2, Task3)
├── context_switch.s     # Changement de contexte en assembleur ARM
│
├── mini_rtos.uvprojx    # Fichier projet Keil MDK
├── mini_rtos.uvoptx     # Options de debug Keil
│
└── RTE/
    └── Device/
        └── ARMCM0/
            ├── startup_ARMCM0.s   # Vecteurs d'interruption ARM Cortex-M0
            └── system_ARMCM0.c    # Initialisation système
```

---

## Fonctionnement

### Ordonnancement Round-Robin

```
Task1 (1ms) → Task2 (1ms) → Task3 (1ms) → Task1 → ...
```

Chaque tâche reçoit un quantum de temps égal de 1 ms, calculé par :

```c
nextTask = (currentTask + 1) % MAX_TASKS;
```

### Architecture des interruptions

| Exception | Priorité | Rôle |
|-----------|----------|------|
| SysTick   | Élevée   | Sélectionne la tâche suivante, déclenche PendSV |
| PendSV    | Très basse | Effectue le changement de contexte |

### Changement de contexte (context_switch.s)

À chaque interruption PendSV :
1. Le CPU sauvegarde automatiquement `R0–R3, R12, LR, PC, xPSR` (frame HW)
2. PendSV sauvegarde manuellement `R4–R11` (frame SW) sur le PSP de la tâche
3. `tcb[currentTask].sp` est mis à jour
4. Le contexte de la nouvelle tâche est restauré dans l'ordre inverse
5. `BX LR` avec `EXC_RETURN = 0xFFFFFFFD` → le CPU restaure le frame HW

### Task Control Block (TCB)

```c
typedef struct {
    uint32_t *sp;           // Pointeur de pile sauvegardé (offset 0)
    uint32_t  stack[128];   // Pile privée (512 octets)
} TCB;                      // sizeof(TCB) = 516 octets
```

---

## Variables observables dans Keil (Watch 1)

| Variable | Description |
|----------|-------------|
| `active_task_id` | Tâche en cours d'exécution (1, 2 ou 3) |
| `c1` | Compteur de Task1 (0 → 10 → 0 → ...) |
| `c2` | Compteur de Task2 (0 → 20 → 0 → ...) |
| `c3` | Compteur de Task3 (1 → 21 → 1 → ...) |
| `task_switches` | Nombre total de changements de tâche |
| `currentTask` | Indice interne (0, 1 ou 2) |

---

## Prérequis

- **Keil MDK** v5 ou supérieur
- **Compilateur ARMCC V5** (inclus dans Keil MDK)
- Pack CMSIS pour ARM Cortex-M0

## Utilisation

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/<votre-username>/mini-rtos-cortexm0.git
   ```
2. Ouvrir `mini_rtos.uvprojx` dans Keil MDK
3. Compiler : `Project → Build Target` (F7)
4. Lancer la simulation : `Debug → Start/Stop Debug Session` (Ctrl+F5)
5. Dans `View → Watch Windows → Watch 1`, ajouter `active_task_id`, `c1`, `c2`, `c3`
6. Cliquer `Run` (F5) et observer les variables changer en alternance

---

## Licence

Projet académique — ESPA Antananarivo, 2025-2026.
