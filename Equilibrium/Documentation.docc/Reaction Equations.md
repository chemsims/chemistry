# Equilibrium Reaction Equations

This page explains the equations used in the equilibrium reactions

## Aqueous Reaction

### Reaction definition & terms

The reaction is in the form `CaA + CbB ⇌ CcC + CdD`. 

A, B, C and D represent different types of molecules. A and B are the reactants, while C and D are 
the products. Ca, Cb, Cc and Cd are the coefficients of each type of molecule.

Each reaction has an equilibrium constant, `K`. These are defined in the type ``Equilibrium/AqueousReactionType``.

The three aqueous reactions are:

- A + B ⇌ C + D. K = 0.75.
- 3A + 2B ⇌ C + 2D. K = 10.
- 2A + 3B ⇌ C + 4D. K = 2.

### Forward reaction concentrations

The goal is to find an equation for the concentration of each molecule. In the equilibrium unit,
it's enough to know the concentration at the start and end of the reaction, and then we can come up 
with a link between them.

The steps for the forward reaction are:

1. User sets the initial concentration, by adding molecules to the beaker.
2. Solve the quotient equation to find the unit change in concentration.
3. Use the unit change to find the equilibrium concentration of each molecule.
4. Use the equilibrium concentration to get the concentration equation.

#### Finding the unit change

The quotient equation is:

```
Q = ([C]^Cc * [D]^Cd)/([A]^Ca * [B]^Cb)
```

The square brackets indicate concentration, so `[C]` is the concentration of the molecule C for example.

Equilibrium is reached when Q = K, and we need to figure out the concentration of each molecule
when we reach equilibrium.

At equilibrium, each concentration will have changed by an amount proportional to it's coefficient. 
For example, say we have reactant A with a coefficient of 1, and its concentration decreases by an 
amount X. If we have product C with a coefficient of 2, then it's concentration will increase by 2X.

We can write the quotient equation at equilibrium in terms of X, and the initial concentrations 
(A0, B0, C0 and D0). Note that we call X the unit change.

```
Q = K = ((C0 + CcX)^Cc * (D0 + CdX)^Cd) / ((A0 - CaX)^Ca * (B0 - CbX)^Cb)
```

Notice that because this is the forward reaction, the concentrations of the reactants (A & B) 
decrease, while the concentrations of the products (C & D) increase.

The goal is to solve this equation for X.

In general, there is no analytical solution for this equation, so it must be solved numerically. 
The implementation to solve the equation is in ``Equilibrium/ReactionConvergenceSolver``.
That implementation uses a binary search method, and iterates up to 50 times or until Q is within 
0.0001 of K.

The binary search needs an initial lower bound and upper bound. The lower bound is 0, and the upper
bound is the largest drop in concentration that we could possibly see. For the forward reaction,
this is the initial concentration of A or B, divided by their coefficients. This is because if X
was any larger than this, then the final concentrations would be less than 0.

```
min((A0 / Ca), (B0 / Cb))
```

For the reverse reaction, we instead use C or D. i.e.,

```
min((C0 / Cc), (D0 / Cd))
```

#### Find equilibrium concentration

Once we have the unit change X, we can find the equilibrium concentration of each molecule. For example, 
for the molecule A:

```
Aeq = A0 - CaX
```

#### Concentration equation

Now we need an equation to get the concentration at any point between the initial time and 
equilibrium time. There is no underlying chemistry modelling for this, instead the curve should 
just look about right. 

For this, we use a quadratic equation for each molecule. We know the initial and equilibrium 
concentrations, and we can say that at the equilibrium time the gradient of the curve should be 0 
(i.e., it is at it's parabola).

This gives us enough information to find the coefficient of each term of the quadratic equation.

Notice in the graphs that once the concentrations reach equilibrium, they stay constant for a few 
seconds. This is achieved by simply switching between the quadratic equation and a constant equation
between the equilibrium time and final reaction time.

##### Solving quadratic equation

If we have a quadratic equation in the form `ax^2 + bx + c`, and we know the coordinates of the 
parabola and some other point, then we can find the coefficients.

Let xp and yp be the x and y coordinates at the parabola, and let x and y be some other coordinate
the curve passes through. Note that if aDenom is 0 then there is no solution.

```
aNumer = (y - yp)
aDenom = (x^2) - (2 * xp * x) + (xp^2)

a = aNumer / aDenom
b = -2 * a * xp
c = yp + (a * xp^2)
```

The x and y values correspond to the reaction like this:

- x: Initial concentration
- y: Initial time
- xp: Concentration at equilibrium
- yp: Time at equilibrium

### Reverse reaction concentrations

The reverse reaction follows the same process as the forward reaction, with 2 differences:

1. For the initial concentrations, we use the final concentrations of the forward reaction, plus 
any other molecules the user may add to the products.
2. The signs in the quotient equation are flipped. i.e.:

```
Q = K = ((C0 - CcX)^Cc * (D0 - CdX)^Cd) / ((A0 + CaX)^Ca * (B0 + CbX)^Cb)
```

Notice the products (C & D) are now decreasing, while the reactants (A & B) are increasing.

Also notice that in this equation, when X increases, Q decreases. This means the binary search is slightly
different to the forward reaction case. In this case, if Q is too high, we should keep looking for a
higher X, not a lower X. 

Apart from this, the process is exactly the same. We will have 2 concentration equations for each 
molecule. We can simply switch between them, depending on what stage of the reaction we're in.

##### Related models

Below are some related models:

- ``ReactionsCore/Equation``
- ``ReactionsCore/SwitchingEquation``
- ``ReactionsCore/QuadraticEquation``
- ``Equilibrium/BalancedReactionEquation``
- ``Equilibrium/EquilibriumReactionEquation``
- ``Equilibrium/ReactionQuotientEquation``

There are also some tests which check the implementations.

- ``EquilibriumTests/BalancedReactionEquationTests``
- ``EquilibriumTests/ReactionConvergenceSolverTests``
- ``EquilibriumTests/ReactionComponentTests``
