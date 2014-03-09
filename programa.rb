
#########################################
#                                       #
#       PROCESAMIENTO DE DATOS          #
#                                       #
#########################################

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

resultado_4dec = [0.379, 0.2162, 0.3221, 0.3446, 0.0564, 0.0228]
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

  norma = mesa.map {|votos| (votos.to_f / peso).round(10)}
  return norma
end

resultado_exacto = normalizar_una(votos_por_partido)

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
  
def errabs(a, b)
  dif = [a,b].transpose.map {|x| x.reduce(:-).abs}
  return dif.reduce(:+)*100
end

def simular_un_escrutinio(mesas)
  normalizar_muchas(suma_parcial(mezclar_mesas(mesas)))
end

curfile = File.open("simuescru.dat", "w")
curfile.write(simular_un_escrutinio(votos_mesas))
curfile.close

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
  repeticiones.times do |i|
    muestras << muestra_general(agregado, tamano_muestra)
    p "#{i}, #{tamano_muestra}"
  end
  return muestras
end


############################  Datos Oficiales  #################################
# Simulaciones escrutinio
escrutinios = []
i = 1
10_000.times do
  escrutinios << simular_un_escrutinio(votos_mesas)
    p i
    i +=1
end

puts "escrutinios"
# 1. Maximos y minimos obtenidos por Carrio y Bergman contadas N mesas.
# maximos(simulaciones,  candidato)
#
# Del array de s simulaciones, tomo unicamente los porcentajes conrrespondientes a 'candidato' y desecho el resto. Obtengo un array de s * n (n = numero de agregados)
# Traspongo el array y obtengo uno donde en cda posicion, estan los s porcentajes que el candidato obtuvo hasta la mesa i.
# Tomo el maximo o minimo del array en cada posicion.
# Devuebo un array de n posiciones, cada una con el max/min porcentaje obtenido por el candidato hasta entonces

def tomar_valores_candidato(mesas, candidato)
  valores_candidato = []
  mesas.each do |mesa|
    valores_candidato << mesa[candidato]
  end
  return valores_candidato
end



def limites(simulaciones, candidato, tomar_max = true)
  valores_candidato = []
  simulaciones.each do |sim|
    valores_candidato << tomar_valores_candidato(sim, candidato)
  end
  limites = []
  valores_candidato.transpose.each_with_index do |porcs, i|
    if tomar_max
      limites << porcs.sort.pop()
    else
      limites << porcs.sort.shift()
    end
  end
  return limites
end  

curfile = File.open("max_carrio.dat", "w")
limites(escrutinios, 2, true).each_with_index do |x, i| 
  curfile.puts "#{i + 1} #{x}"
end
curfile.close

curfile = File.open("min_carrio.dat", "w")
limites(escrutinios, 2, false).each_with_index do |x, i| 
  curfile.puts "#{i + 1} #{x}"
end
curfile.close

curfile = File.open("max_bergman.dat", "w")
limites(escrutinios, 3, true).each_with_index do |x, i| 
  curfile.puts "#{i + 1} #{x}"
end
curfile.close

curfile = File.open("min_bergman.dat", "w")
limites(escrutinios, 3, false).each_with_index do |x, i| 
  curfile.puts "#{i + 1} #{x}"
end
curfile.close

puts "1 done"

# 2. Plotear 100 deltaerrorsim(sim) en una misma figura

def errabs_escrutinio(escrutinio)
  errabs = []
  for i in 0..escrutinio.length-1
    errabs[i] = errabs(escrutinio[i], escrutinio[-1])
  end
  return errabs
end

def delta_serie(serie)
  delta_serie = []
  for i in 0..(serie.length-1)
    delta_serie << serie[i]-serie[i-1]
  end
  return delta_serie
end

escrutinios.first(500).each_with_index do |escrutinio, index|
  curfile = File.open("escrutinio#{index}.dat", "w")
  deltas = delta_serie(errabs_escrutinio(escrutinio))
  deltas.each_with_index do |delta, i|
    curfile.puts "#{i + 1} #{delta}"
  end
  curfile.close
end

puts "2 done"

# 3. Histogramas estalizacion errabs escrutinios



def estabilizacion_errabs(escrutinios)
  resultados = []
  escrutinios.each do |escrutinio|
    deltas_invertidos = delta_serie(errabs_escrutinio(escrutinio)).reverse!
    puntos_criticos = []
    deltas_invertidos.each_with_index do |paso, i|
      if paso > 0.01 && puntos_criticos.length == 0
        puntos_criticos << escrutinio.length - i
      elsif paso > 0.1 && puntos_criticos.length == 1
        puntos_criticos << escrutinio.length - i
      elsif paso > 1 && puntos_criticos.length == 2
        puntos_criticos << escrutinio.length - i
      elsif paso > 10 && puntos_criticos.length == 3
        puntos_criticos << escrutinio.length - i
        break
      else
      end
    end
    puntos_criticos.push(0) if puntos_criticos.length == 3
    resultados << puntos_criticos
  end
  return resultados
end

puntos_criticos_por_nivel = estabilizacion_errabs(escrutinios).transpose.map {|x| x.sort!}
puntos_criticos_por_nivel.each_with_index do |puntos, i|
  curfile = File.open("quiebres#{i}.dat", "w")
  puntos.each_with_index do |p, i|
    curfile.puts "#{i + 1} #{p}"
  end
  curfile.close
end

puts "3 done"

# 4. Histogramas de error de 100k muestras tamano 100, 500, 2000, 10000

# muestreo_repetido(agregado, tamano_muestra, repeticiones)

quinientos = []
10000.times do
  quinientos << errabs(muestra_general(votos_circuitos, 500), resultado_exacto)
end
quinientos.sort!
curfile = File.open("quinientos.dat", "w")
quinientos.each_with_index do |errabs, i|
  curfile.puts "#{i + 1} #{errabs}"
end
curfile.close

dosmil = []
10000.times do
  dosmil << errabs(muestra_general(votos_circuitos, 2000), resultado_exacto)
end
dosmil.sort!
curfile = File.open("dosmil.dat", "w")
dosmil.each_with_index do |errabs, i|
  curfile.puts "#{i + 1} #{errabs}"
end
curfile.close

diezmil = []
10000.times do
  diezmil << errabs(muestra_general(votos_circuitos, 10000), resultado_exacto)
end
diezmil.sort!
curfile = File.open("diezmil.dat", "w")
diezmil.each_with_index do |errabs, i|
  curfile.puts "#{i + 1} #{errabs}"
end
curfile.close

cien = []
10000.times do
  cien << errabs(muestra_general(votos_circuitos, 100), resultado_exacto)
end
cien.sort!
curfile = File.open("cien.dat", "w")
cien.each_with_index do |errabs, i|
  curfile.puts "#{i + 1} #{errabs}"
end
curfile.close

enes_grafico_cinco = []
for i in 0..20
  enes_grafico_cinco << (10**(1 + 4.0 / 20 * i)).to_i
end

puts "4 done"

# 5. Percentiles comparados

muestras_grafico_cinco = []

enes_grafico_cinco.each do |ene|
  muestras_ene = []
  10000.times do
    muestras_ene << errabs(muestra_general(votos_circuitos, ene), resultado_exacto)
  end
  muestras_ene.sort!
  muestras_grafico_cinco << muestras_ene
end

percentiles =  [1, 5, 10, 50, 90, 95, 99]
for perc in percentiles do
  curfile = File.open("perc#{perc}.dat", "w")
  muestras_grafico_cinco.each_with_index do |muestras, i|
    curfile.puts "#{enes_grafico_cinco[i]} #{muestras[perc*100]}"
  end
  curfile.close
end

puts "5 done"
########################### Borrador - Pruebas ################################
=begin
normalizar_muchas(suma_parcial(mezclar_mesas(votos_mesas)).first(50)).each_with_index do |x, i|
  print "#{i + 1}"
  x.each { |y| print " #{'%.2f' % (y*100)}"}
  puts
end
 =end

=begin
# Codigo para generar el escrutinio de ejemplo
normalizar_muchas(suma_parcial(mezclar_mesas(votos_mesas))).each_with_index do |x, i|
  print "#{i + 1}"
  x.each { |y| print " \& #{'%.2f' % (y*100)}"}
  puts
end
=end

=begin
# codigo para generar muestras de ejemplo
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
=end
