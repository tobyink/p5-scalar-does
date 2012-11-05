use inc::Module::Package 'RDF 0.009';

requires('UNIVERSAL::DOES',0) if $] < 5.010;
dynamic_config;
