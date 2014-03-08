
#########################################
#                                       #
#       PROCESAMIENTO DE DATOS          #
#                                       #
#########################################
probar = false

# Guardo cada linea del input en el array 'mesas_raw'

mesas_raw     = IO.readlines(Dir.pwd + "/mesas_raw.tsv")
circuitos_raw = IO.readlines(Dir.pwd + "/circuitos_raw.tsv")
secciones_raw   = IO.readlines(Dir.pwd + "/secciones_raw.tsv")


def emprolijar_agregado(agregado)
  
  # Elimino la primer linea del archivo, que contiene los titulos de las columnas:
  agregado.shift()

  # Formateo cada division del agregado (mesas, circuitos o secciones) para transformarla en un array de numeros enteros y las guardo en mesas_completas.
  agregado_prolijo = []
  for division in agregado
    # quito el \n del final de la linea, la corto sobre los tabs y transformo a enteros el array resultante
    agregado_prolijo << division.chomp.split("\t").map { |x| x.to_i}
  end

  # Hasta aqui, cada division del agregado tiene ocho campos: su numero identificador en la primera, el total de votos que cada uno de los 6 partidos saco de la 2 a la 7, y blancos en la 8.
  # Con la proxima linea eliminamos el primer elemento de cada array, para dejar solo las cantidades de votos.
  agregado_prolijo.each {|division| division.shift(1)}

  # Si se quiere realizar el analisis CON VOTOS EN BLANCO, descomentar la proxima linea:
  agregado_prolijo.each {|division| division.pop(1)}

  return agregado_prolijo
end

votos_mesas     = emprolijar_agregado(mesas_raw)
votos_circuitos = emprolijar_agregado(circuitos_raw)
votos_secciones = emprolijar_agregado(secciones_raw)

#########################
#                       #
#      HIPOTESIS II     #
#                       #
#########################

# Variables auxiliares.

mesas_test = []
votos_mesas.first(5).each {|x| mesas_test << x}

# resultados = [0.379, 0.2162, 0.3221, 0.3446, 0.0564, 0.0228]
votos_por_partido = [68_246, 389_128, 581_096, 621_167, 101_862, 41_194]
votos_afirmativos = 1_802_693


def mezclar_mesas(mesas)
  mesas_mezcladas = mesas.shuffle
  return mesas_mezcladas
end

def sumar_arrays(arrays)
  arrays.transpose.map {|x| x.reduce(:+)}
end

def suma_parcial(mesas)
  sumas_parciales = []
  sumas_parciales[0] = mesas[0]
  for i in (1..mesas.length-1)
    sumas_parciales[i]= sumar_arrays([sumas_parciales[i-1], mesas[i]])
  end
  return sumas_parciales
end

def normalizar_una(mesa)
  peso = mesa.reduce(:+)
  peso = 1 unless peso != 0 # En caso de que se tomen 0 votos de una mesa, esta linea impide que se dividan los resultads por cero.

  norma = mesa.map {|votos| (votos.to_f / peso).round(4)}
  return norma
end

def normalizar_muchas(mesas)
  normas = []
  mesas.each do |mesa|
    normas << normalizar_una(mesa)
  end
  return normas
end

def ecm(a, b)
  dif = [a, b].transpose.map {|x| x.reduce(:-)}
  dif.map! {|x| x**2}
  return dif.reduce(:+)
end
  

def simular_limite(n, mesas, referencia)
  results = []
  n.times do
    serie = normalizar_muchas(suma_parcial(mezclar_mesas(mesas))).reverse!
    serie.each_with_index do |mesa, i|
      error = (ecm(mesa, referencia)*10_000).round(2)
      
      if error > 1
        results << mesas.length - i + 1
        break
      
      else
      end
    end
  end
  return results
end


if probar
  a = simular_limite(100, votos_mesas, normalizar_una(votos_por_partido))
  a.sort!

  a.each_with_index do |x, i|
    puts "percentil #{i+1}: #{x}"
  end
  else
end


#########################
#                       #
#      HIPOTESIS I      #
#                       #
#########################

def pesos(mesas)
  pesos_mesas = []
  mesas.each do |mesa|
    pesos_mesas << mesa.reduce(:+)
  end
  return pesos_mesas
end

pesos_mesas = pesos(votos_mesas)
pesos_circuitos = pesos(votos_circuitos)
pesos_secciones = pesos(votos_secciones)

# Dado el tamano de muestra deseado, calcular cuantos votos sacar de cada agregado.

def tamanos_muestra_discreta(votos_agregado, n)
  
  peso_total = pesos(votos_agregado).reduce(:+)
  votos_por_mesa = pesos(votos_agregado).map {|x| (x.to_f / peso_total * n).round(2)}
  votos_por_mesa_discretos = []
  votos_por_mesa.each do |votos|
    if rand < votos % 1
      votos_por_mesa_discretos << (votos.to_i + 1)
    else
      votos_por_mesa_discretos << (votos.to_i)
    end
  end
  return votos_por_mesa_discretos
end

# Tomar 'cantidad' votos de la mesa 'mesa', al azar, sin repetir.

def muestra_por_mesa(mesa, cantidad)
  copia_mesa = mesa.dup
  votos_elegidos = []
  peso_mesa = mesa.reduce(:+)
  while votos_elegidos.length < cantidad
    n = copia_mesa.reduce(:+)
    sorteo = rand(1..n)
    voto_actual = 0
    
    while sorteo > copia_mesa.first(voto_actual+1).reduce(:+)
      voto_actual +=1
    end
    
    votos_elegidos << voto_actual
    copia_mesa[voto_actual] -= 1
  end
  
  return pesar_muestra(agregar_votos(votos_elegidos), peso_mesa)
end

# Dado un conjunto de mesas (o circuitos, o secciones), y una cantidad de votos a muestrear de ellos, crear la muestra. Involucra primero una llamada a tamano_muestra_discreta() que devuelve los votos a tomar por mesa, y luego a muestra_por_mesa(), que toma los votos anteriormente indicados de cada mesa.

def muestra_general(mesas, cantidad)
  muestras_por_mesa = []
  
  votos_por_mesa = tamanos_muestra_discreta(mesas, cantidad)
  
  for i in 0..mesas.length-1
    muestras_por_mesa << muestra_por_mesa(mesas[i], votos_por_mesa[i])
  end

  muestra_general = sumar_arrays(muestras_por_mesa)

  return normalizar_una(muestra_general)
end

def agregar_votos(votos)
  votos_agregados = Array.new(6, 0)
  votos.each do |voto|
    votos_agregados[voto] += 1
  end
  return votos_agregados
end

def pesar_muestra(muestra, peso)
  return normalizar_una(muestra).map {|votos| votos * peso}
end

def muestreo_repetido(agregado, tamano_muestra, repeticiones)
  muestras = []
  repeticiones.times do
    muestras << muestra_general(agregado, tamano_muestra)
  end
  return muestras
end

# muestreo_repetido(votos_mesas, 500, 20)

############################ Borrador - Pruebas ################################

=begin
# Codigo para generar el escrutinio de ejemplo
normalizar_muchas(suma_parcial(mezclar_mesas(votos_mesas))).each_with_index do |x, i|
  print "#{i + 1}"
  x.each { |y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
=end

# muestreo_repetido(votos_circuitos, 10, 2)

muestreo_repetido(votos_circuitos, 10, 5).each do |x|
  print "#{10}"
  x.each {|y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
muestreo_repetido(votos_circuitos, 100, 5).each do |x|
  print "#{100}"
  x.each {|y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
muestreo_repetido(votos_circuitos, 1000, 5).each do |x|
  print "#{1000}"
  x.each {|y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
muestreo_repetido(votos_circuitos, 10000, 5).each do |x|
  print "#{10000}"
  x.each {|y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
