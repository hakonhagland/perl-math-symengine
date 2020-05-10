// NOTE: The below include must come before the include for the perl header perl.h,
// or else the compiler will get confused regarding the seed() function definition
//  in symengine/mp_class.h
#include <symengine/matrix.h>
#include <symengine/symengine_rcp.h>
#include <string>
#include <unordered_map>
#include <variant>

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
//
// The ppport.h include file was generated using:
//   $ perl -MDevel::PPPort -E 'Devel::PPPort::WriteFile
//
#include "ppport.h"       // allow the module to be built using older versions of Perl

#define MY_CXT_KEY "Math::SymEngine::_guts" XS_VERSION

using RCP_Basic = SymEngine::RCP<const SymEngine::Basic>;
using RCP_Integer = SymEngine::RCP<const SymEngine::Integer>;
using RCP_Symbol = SymEngine::RCP<const SymEngine::Symbol>;
using RCP_Any = std::variant<RCP_Basic, RCP_Integer, RCP_Symbol>;

using SymFunc = RCP_Basic (*)(const RCP_Basic&);

typedef struct {
    long sym_id = 1;  // TODO: even if a long can hold a huge number,
                    //  an item in the map might teoretically be overwritten 
                  //  if one id does not get deleted before the sym_id
                //  counter has wrapped around.
              // What would be a better approach to avoid this problem?
    std::unordered_map<int,RCP_Any> symbols;
} my_cxt_t;

// make the static variables in my_cxt_t thread safe by using the MY_CXT framework,
// see perldoc perlxs for more information
START_MY_CXT

IV get_hash_iv(HV *hash, const char *key)
{
    SV * key_sv = newSVpv(key, strlen (key));
    IV value;
    if (hv_exists_ent (hash, key_sv, 0)) {
        HE *he = hv_fetch_ent (hash, key_sv, 0, 0);
        SV *val = HeVAL (he);
        if (SvIOK (val)) {
            value = SvIV(val);
        }
        else {
            croak("Value of hash key '%s' is not a number", key);
        }
    }
    else {
        croak("The hash key for '%s' doesn't exist", key);
    }
    return value;
}

// create math symengine symbol object
SV *create_mss_object( RCP_Any sym, const char *obj_type )
{
    IV id = MY_CXT.sym_id++;
    MY_CXT.symbols[id] = sym;  // copy into map
    HV *hash = newHV();
    SV *self = newRV_noinc( (SV *) hash );
    SV *sv_sym = newSViv(id);
    hv_store (hash, "_sym", strlen ("_sym"), sv_sym, 0);
    SV *sv_name = newSVpvf( "%s::%s", "Math::SymEngine", obj_type);
    char* name = SvPV_nolen(sv_name);
    SV *obj = sv_bless(self, gv_stashpv( name, GV_ADD ) );
    SvREFCNT_dec(sv_name);
    return obj;
}

SV *create_dense_mat_object( SymEngine::DenseMatrix *mat)
{
    HV *hash = newHV();
    SV *self = newRV_noinc( (SV *) hash );
    SV *sv_mat = newSViv(PTR2IV(mat));
    hv_store (hash, "_mat", strlen ("_mat"), sv_mat, 0);
    return sv_bless(self, gv_stashpv( "Math::SymEngine::DenseMatrix", GV_ADD ) );
}

SV *create_integer_object( RCP_Integer &sym )
{
    return create_mss_object( sym, "Integer" );
}

SV *create_basic_object( RCP_Basic &sym )
{
    return create_mss_object( sym, "Basic" );
}

SV *create_symbol_object( char *name )
{
    auto sym = SymEngine::symbol(name);
    return create_mss_object( sym, "Symbol" );
}


HV *get_object_hash(SV *svrv, const char *isa)
{
    if (!sv_isobject(svrv)) {
        croak("Argument is not a blessed reference!");
    }
    if (!sv_derived_from(svrv, isa)) {
        croak("Argument is not an object of type %s", isa);           
    }
    SV *sv = SvRV(svrv);
    if ((SvTYPE(sv) != SVt_PVHV)) {
        croak("Argument is not a blessed hash ref!");
    }
    HV *hash = (HV *) sv;
    return hash;
}

class SymFuncVisitor
{
public:
    SymFuncVisitor(SymFunc func) : func_(func) {}
    RCP_Basic operator()(RCP_Basic sym) const {
        return func_(sym); 
    }
    RCP_Basic operator()(RCP_Integer sym) const {
        return func_(sym); 
    }
    RCP_Basic operator()(RCP_Symbol sym) const {
        return func_(sym); 
    }
private:
    SymFunc func_;
};

struct CastVisitor
{
    RCP_Basic operator()(RCP_Basic sym) const {
        return sym;
    }
    RCP_Basic operator()(RCP_Integer sym) const {
        return SymEngine::rcp_static_cast<const SymEngine::Basic>(sym);
    }
    RCP_Basic operator()(RCP_Symbol sym) const {
        return SymEngine::rcp_static_cast<const SymEngine::Basic>(sym);
    }
};

RCP_Basic cast_variant_symbasic(RCP_Any sym)
{
    return std::visit(CastVisitor{}, sym);
}       

RCP_Basic call_sym_func(RCP_Any sym, SymFunc func)
{
    return std::visit(SymFuncVisitor{func}, sym);
}

RCP_Any get_object_symbol_value(SV *sym_sv)
{
    dMY_CXT;
    HV *hash = get_object_hash(sym_sv, "Math::SymEngine::Basic");
    IV id = get_hash_iv(hash, "_sym");
    return MY_CXT.symbols[id];
}

SymEngine::DenseMatrix *get_matrix_ptr( SV *class_sv )
{
    HV *mat_hash = get_object_hash(class_sv, "Math::SymEngine::DenseMatrix");
    IV addr = get_hash_iv(mat_hash, "_mat");
    SymEngine::DenseMatrix *mat = (SymEngine::DenseMatrix *) INT2PTR(SV*, addr);
    return mat;
}

void erase_symbol( SV *sv)
{
    dMY_CXT;
    HV *hv = (HV *) SvRV(sv);
    IV id = get_hash_iv(hv, "_sym");
    MY_CXT.symbols.erase(id);
}

MODULE = Math::SymEngine  PACKAGE = Math::SymEngine

PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;
}
    
SV *
sym(sym)
    SV *sym
  CODE:
    char* name = SvPV_nolen(sym);
    RETVAL = create_symbol_object( name );
  OUTPUT:
    RETVAL

SV *
mul(syma_sv, symb_sv)
    SV *syma_sv
    SV *symb_sv
  CODE:
    auto syma = get_object_symbol_value(syma_sv);
    auto symb = get_object_symbol_value(symb_sv);
    auto sa = cast_variant_symbasic(syma);
    auto sb = cast_variant_symbasic(symb);
    auto result = SymEngine::mul(sa, sb);
    RETVAL = create_basic_object( result );
  OUTPUT:
    RETVAL

SV *
cos(sym_sv)
    SV *sym_sv
  CODE:
    auto sym = get_object_symbol_value(sym_sv);
    auto new_sym = call_sym_func(sym, SymEngine::cos);
    RETVAL = create_basic_object( new_sym );
  OUTPUT:
    RETVAL

SV *
sin(sym_sv)
    SV *sym_sv
  CODE:
    auto sym = get_object_symbol_value(sym_sv);
    auto new_sym = call_sym_func(sym, SymEngine::sin);
    RETVAL = create_basic_object( new_sym );
  OUTPUT:
    RETVAL

SV *
integer(value)
    IV value
  CODE:
    auto sym = SymEngine::integer(value);
    RETVAL = create_integer_object( sym );
  OUTPUT:
    RETVAL

SV *
mul_dense_dense(a_sv, b_sv)
    SV *a_sv
    SV *b_sv
  CODE:
    auto *mata = get_matrix_ptr( a_sv );
    auto *matb = get_matrix_ptr( b_sv );
    unsigned size_i = mata->nrows();
    unsigned size_j = matb->ncols();
    auto *matc =
        new SymEngine::DenseMatrix {(unsigned)size_i, (unsigned)size_j};
    mata->mul_matrix(*matb, *matc);
    RETVAL = create_dense_mat_object(matc);
  OUTPUT:
    RETVAL

MODULE = Math::SymEngine  PACKAGE = Math::SymEngine::DenseMatrix

SV *
new(class_sv, size_i, size_j)
    SV *class_sv
    UV size_i
    UV size_j
  CODE:
    auto *mat =
        new SymEngine::DenseMatrix {(unsigned)size_i, (unsigned)size_j};
    RETVAL = create_dense_mat_object(mat);
  OUTPUT:
    RETVAL

void
set(class_sv, i_idx, j_idx, val )
    SV *class_sv
    UV i_idx
    UV j_idx
    SV *val
 CODE:
    auto sym_var = get_object_symbol_value(val);
    auto *mat = get_matrix_ptr( class_sv );
    auto sym = cast_variant_symbasic(sym_var);
    mat->set(i_idx, j_idx, sym );

SV *
to_string(class_sv)
    SV *class_sv
 CODE:
    auto *mat = get_matrix_ptr( class_sv );
    std::string str = mat->__str__();
    const char *cstr = str.c_str();
    SV *sv = newSVpvn(cstr, strlen(cstr));
    RETVAL = sv;
  OUTPUT:
    RETVAL

void
DESTROY(self)
   SV *self
 PREINIT:
   dMY_CXT;
 CODE:
   HV *hv = (HV *) SvRV(self);
   IV id = get_hash_iv(hv, "_mat");
   SymEngine::DenseMatrix *mat = (SymEngine::DenseMatrix *) INT2PTR(SV*, id);
   delete mat;

            
MODULE = Math::SymEngine  PACKAGE = Math::SymEngine::Basic

void
DESTROY(self)
   SV *self
 CODE:
   erase_symbol(self);

MODULE = Math::SymEngine  PACKAGE = Math::SymEngine::Integer

void
DESTROY(self)
   SV *self
 CODE:
   erase_symbol(self);

MODULE = Math::SymEngine  PACKAGE = Math::SymEngine::Symbol

SV *
new(class_sv, name_sv)
    SV *class_sv
    SV *name_sv
  CODE:
    char* name = SvPV_nolen(name_sv);
    RETVAL = create_symbol_object( name );
  OUTPUT:
    RETVAL

void
DESTROY(self)
   SV *self
 CODE:
   erase_symbol(self);
