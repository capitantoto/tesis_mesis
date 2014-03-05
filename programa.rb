
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

def suma_parcial(mesas)
  sumas_parciales = []
  sumas_parciales[0] = mesas[0]
  for i in (1..mesas.length-1)
    sumas_parciales[i]= [sumas_parciales[i-1], mesas[i]].transpose.map {|x| x.reduce(:+)}
  end
  return sumas_parciales
end

def normalizar_una(mesa)
  peso = mesa.reduce(:+)
  norma = mesa.map {|votos| (votos.to_f / peso).round(4)}
  return norma
end

def normalizar_muchas(mesas)
  normas = []
  mesas.each do |mesa|
#    p normalizar_una(mesa)
#    gets
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
#      puts "Evaluando #{mesa}, paso #{i} el ECM es #{error}"
#      gets
      
      if error > 1
#        puts mesas.length - i + 1
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
#  p votos_por_mesa
  votos_por_mesa_discretos = []
  votos_por_mesa.each do |votos|
    if rand < votos % 1
      votos_por_mesa_discretos << (votos.to_i + 1)
    else
      votos_por_mesa_discretos << (votos.to_i)
    end
  end
#  p votos_por_mesa_discretos
  return votos_por_mesa_discretos
end

# Tomar 'cantidad' votos de la mesa 'mesa', al azar, sin repetir.

def muestra_por_mesa(mesa, cantidad)
  copia_mesa = mesa.dup
  votos_elegidos = []
  
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
  
  return votos_elegidos
end

# Dado un conjunto de mesas (o circuitos, o secciones), y una cantidad de votos a muestrear de ellos, crear la muestra. Involucra primero una llamada a tamano_muestra_discreta() que devuelve los votos a tomar por mesa, y luego a muestra_por_mesa(), que toma los votos anteriormente indicados de cada mesa.

def muestra_general(mesas, cantidad)
  muestra_general = []
  
  votos_por_mesa = tamanos_muestra_discreta(mesas, cantidad)
  
  for i in 0..mesas.length-1
    muestra_por_mesa(mesas[i], votos_por_mesa[i]).each do |voto|
      muestra_general.push(voto)
    end
  end

  return muestra_general
end


def sampleo_general(mesas)
  sampleo = []
  mesas.each_with_index do |mesa, i|
    samp = samplear_por_mesa(mesa)
    puts "La mesa #{i} sampleo #{samp}. Woohoo!"
    sampleo << samp
  end
  puts
  return sampleo
end


10.times do
t = muestra_general(votos_mesas, 5000)
b = Array.new(6, 0)
t.each {|x| b[x]+=1}
p (ecm(normalizar_una(b), normalizar_una(votos_por_partido))*10_000).round(2)
end

p '='*20


10.times do
t = muestra_general(votos_circuitos, 5000)
b = Array.new(6, 0)
t.each {|x| b[x]+=1}
p (ecm(normalizar_una(b), normalizar_una(votos_por_partido))*10_000).round(2)
end

p '='*20

10.times do
t = muestra_general(votos_secciones, 5000)
b = Array.new(6, 0)
t.each {|x| b[x]+=1}
p (ecm(normalizar_una(b), normalizar_una(votos_por_partido))*10_000).round(2)
end
=begin Para probar el algoritmo de muestreo
b = []
10000.times do
  a = tamanos_muestra_discreta(500, votos_secciones)
  b << a.reduce(:+)
end

b.sort!

puts "#{b[500]} #{b[4999]} #{b[9500]}"
=end
