/** @file gsHDomainLeafIter.h

    @brief Provides declaration of HDomainLeafIter class.

    This file is part of the G+Smo library.
    
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.

    Author(s): A. Mantzaflaris
*/

#pragma once

#include <gsHSplines/gsKdNode.h>
#include <gsCore/gsTemplateTools.h>

namespace gismo
{

/** 
    Iterates over the leaves of an gsHDomain (tree).
*/

template<typename node, bool isconst = false>
class gsHDomainLeafIter
{
public:
    //typedef kdnode<d, unsigned> node;
    typedef typename choose<isconst, const node&, node&>::type reference;
    typedef typename choose<isconst, const node*, node*>::type pointer;

    typedef typename node::point point;

public:
    reference operator*() const { return *m_curNode; }
    pointer  operator->() const { return  m_curNode; }

public:

    gsHDomainLeafIter() : m_curNode(0)
    { }

    explicit gsHDomainLeafIter( node * const root_node, unsigned index_level)
        : m_index_level(index_level)
    { 
        m_stack.push(root_node);

        // Go to the first leaf
        next();
    }

    // Next leaf
    bool next()
    {
        while ( ! m_stack.empty() )
        {
            m_curNode = m_stack.top();
            m_stack.pop();
            
            if ( m_curNode->isLeaf() )
            {
                return true;
            }
            else // this is a split-node
            {
                m_stack.push(m_curNode->left );
                m_stack.push(m_curNode->right);
            }
        }

        // Leaves exhausted
        m_curNode = NULL;
        return false;
    }

    /// Returns true iff we are still pointing at a valid leaf
    bool good() const   { return m_curNode != 0; }

    /// The iteration is done in the sub-tree hanging from node \start
    void startFrom( node * const root_node)
    {
        m_stack.clear();
        m_stack.push(root_node);
    }

    int level() const { return m_curNode->level; }

    point lowerCorner() const
    { 
        point result = m_curNode->box->first;
        const int lvl = m_curNode->level;

        //result = result.array() / (1>> (m_index_level-lvl)) ;
        for ( index_t i = 0; i!= result.size(); ++i )
            result[i] = result[i] >> (m_index_level-lvl) ;

        return result; 
    }

    point upperCorner() const
    { 
        point result = m_curNode->box->second;
        const int lvl = m_curNode->level;

        for ( index_t i = 0; i!=result.size(); ++i )
            result[i] = result[i] >> (m_index_level-lvl) ;

        return result; 
    }

    unsigned indexLevel() {return m_index_level;}

private:

    // current node
    node * m_curNode;

    /// The level of the box representation
    unsigned m_index_level;

    // stack of pointers to tree nodes, used in next()
    std::stack<node*> m_stack;
};



} // end namespace gismo