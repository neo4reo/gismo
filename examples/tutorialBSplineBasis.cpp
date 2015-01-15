/** @file tutorialGeometry

    @brief Tutorial on gsBSplineBasis class.

    This file is part of the G+Smo library.

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.

    Author(s): J. Speh
*/

// Look also in tuturialBasis for more functionality of gsBSplineBasis.

#include <iostream>
#include <string>
#include <gismo.h>

using namespace gismo;

// forward declaration of some utility functions
void print(const gsBSplineBasis<>& bsb, const std::string& name);
void printToParaview(const gsBSplineBasis<>& bsb, const std::string& name);

int main(int argc, char* argv[])
{
    // ======================================================================
    // different construction of a knot vector
    // ======================================================================
    
    std::cout << "------------- Constructions -----------------------------\n";

    real_t a = 0; // starting knot
    real_t b = 1; // ending knot
    unsigned interior = 4; // number of interior knots
    unsigned multEnd = 3; // multiplicity at the two end knots
    int degree = multEnd - 1;
    gsKnotVector<> kv(a, b, interior, multEnd);
    
    gsBSplineBasis<> bsb0(kv);
    print(bsb0, "bsb0");
    
    gsBSplineBasis<> bsb1(a, b, interior, degree);
    print(bsb1, "bsb1");

    
    // ======================================================================
    // some properties
    // ======================================================================


    std::cout << "------------- Some properties    -----------------------\n\n";
    
    std::cout << "bsb0.size(): " << bsb0.size() << "\n\n"
              << "bsb0.numElements(): " << bsb0.numElements() << "\n\n"
              << "bsb0.degree(): " << bsb0.degree() << "\n\n";


    // ======================================================================
    // some operations
    // ======================================================================

    std::cout << "------------- Some operations    -----------------------\n\n";

    const gsKnotVector<>& knots = bsb0.knots();
    std::cout << "Knots: \n";
    knots.print(std::cout);
    std::cout << "\n\n";

    printToParaview(bsb0, "basis");
    
    std::cout << "bsb0.uniformRefine()\n";
    bsb0.uniformRefine();
    printToParaview(bsb0, "basisRefined");
    
    std::cout << "bsb0.degreeElevate()\n";
    bsb0.degreeElevate();
    printToParaview(bsb0, "basisElevated");
        
    return 0;
}

void printToParaview(const gsBSplineBasis<>& bsb,
                     const std::string& name)
{
    std::cout << "Writing bsb0 to paraview in a file: " << name << "\n\n";
    gsWriteParaview(bsb, name);
}

void print(const gsBSplineBasis<>& bsb,
           const std::string& name)
{
    std::cout << name << ": \n";
    bsb.print(std::cout);
    std::cout << "\n\n";
}

