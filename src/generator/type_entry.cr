module Generator
  class TypeEntry

    TYPEMAP = {
      "char": "Int8",
      "signed char": "Int8",
      "unsigned char": "UInt8",
      "short": "Int16",
      "signed short": "Int16",
      "unsigned short": "UInt16",
      "int": "Int32",
      "signed int": "Int32",
      "unsigned int": "UInt32",
      "int64_t": "Int64",
      "uint64_t": "UInt64",
      "float": "Float32",
      "double": "Float64",
      "ptrdiff_t": "PtrDiffT",
      "void": "Void",
      "void *": "Void",
    }

    property def_name : String = ""
    property ctype_name : String = ""

    def convert_ctype_name
      return TYPEMAP[ctype_name] if TYPEMAP[ctype_name]?
      "Void"
    end
  end
end
