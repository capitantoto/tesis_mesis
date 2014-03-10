#########################################
#                                       #
#       PROCESAMIENTO DE DATOS          #
#                                       #
#########################################

# Tomo los datos a cada nivel de agregacion, y los cargo en sendos [[]]
mesas_raw     = IO.readlines(Dir.pwd + "/mesas_raw.tsv")
circuitos_raw = IO.readlines(Dir.pwd + "/circuitos_raw.tsv")
secciones_raw   = IO.readlines(Dir.pwd + "/secciones_raw.tsv")

# emprolijar_agregado([[]]) => ([[]])
# --Toma el input 'crudo' generado con SQL y devuelve los votos agregados a nivel mesa, circuito o seccion en el formato 'vector de 6 elementos' que utilizan los simuladores.
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

# Guarda el resultados de 'emprolijar' mesas, circuito y secciones en sendas [[]].
votos_mesas     = emprolijar_agregado(mesas_raw)
votos_circuitos = emprolijar_agregado(circuitos_raw)
votos_secciones = emprolijar_agregado(secciones_raw)


#########################
#                       #
#  Funciones Generales  #
#                       #
#########################

# errcuad([], []) => n
# --Suma los cuadrados de las diferencias entre los elementos de dos vectores. Ej: ecm([1,2], [4,3]) => 10
def errcuad(a, b)
  dif = [a, b].transpose.map {|x| x.reduce(:-)}
  dif.map! {|x| x**2}
  return dif.reduce(:+)
end

# errabs([], []) => n
# --Suma las diferencias absolutas entre los elementos de dos vectores. Ej: ecm([1,2], [4,3]) => 4
def errabs(a, b)
  dif = [a,b].transpose.map {|x| x.reduce(:-).abs}
  return dif.reduce(:+)*100
end

# normalizar_una([]) => []
# --Toma los votos por partido obtenidos en una mesa/circuito/seccion ("m/c/s"), y devuelve que proporcion del total representan. Ej: normalizar_una([2,3,5]) => [0.2,0.3,0.5]
def normalizar_una(mesa)
  peso = mesa.reduce(:+)
  peso = 1 unless peso != 0 # En caso de que se tomen 0 votos de una mesa, esta linea impide que se dividan los resultads por cero.
  norma = mesa.map {|votos| (votos.to_f / peso).round(10)}
  return norma
end

############################
#                          #
# Simulador de Escrutinios #
#                          #
############################

# mezclar_mesas([[]]) => [[]]
# -- Toma la matriz de resutlados por mesa, y reordena las filas al azar. Ej: mezclar_mesas([[1,2],[3,4],[5,6],[7,8]]) => [[3,4],[7,8],[5,6],[1,2]]
def mezclar_mesas(mesas)
  mesas_mezcladas = mesas.shuffle
  return mesas_mezcladas
end

# sumar_arrays([[]]) => []
# --Toma un conjunto de vectores, y realiza su suma escalar. Ej: sumar_arrays([1,2],[7,4],[2,8]) = [10,14]
def sumar_arrays(arrays)
  arrays.transpose.map {|x| x.reduce(:+)}
end

# suma_parcial([[]]) => [[]]
# --Toma un conjunto de vectores, y devuelve para cada vector la suma escalar de todos los vectores desde el primero hasta el inclusive. Ej: suma_parcial([1,2],[7,4],[2,8]) = [[1,2],[8,6],[10,14]]   
def suma_parcial(mesas)
  sumas_parciales = []
  sumas_parciales[0] = mesas[0]
  for i in (1..mesas.length-1)
    sumas_parciales[i]= sumar_arrays([sumas_parciales[i-1], mesas[i]])
  end
  return sumas_parciales
end

# normalizar_muchas([[]]) => [[]]
# --Aplica la funcion normalizar_una([]) => [] a cada uno de los elementos de un conjunto de vectores.
def normalizar_muchas(mesas)
  normas = []
  mesas.each do |mesa|
    normas << normalizar_una(mesa)
  end
  return normas
end

# simular_un_escrutinio([[]]) => [[]]
# --Combinando las funciones anterior, corre una simulacion entera de la evolucion de los resutlados la noche del escrutinio. Primero mezcla las mesas, luego hace las sumas parciales hasta cada mesa, y finalmente normaliza los resultados. El ultimo vector de la matriz coincide necesariamente ocn el resultado oficial de la eleccion, siempre.
def simular_un_escrutinio(mesas)
  normalizar_muchas(suma_parcial(mezclar_mesas(mesas)))
end

#########################
#                       #
# Simulador de Muestras #
#                       #
#########################

# pesos([[]]) => []
# --Toma una matriz, y devuelve un vector donde el i-esimo elemento corresponde a la suma de los componentes del i-esimo vector de la matriz original. Ej: pesos([1,2],[7,4],[2,8]) = [3,11,10]
def pesos(mesas)
  pesos_mesas = []
  mesas.each do |mesa|
    pesos_mesas << mesa.reduce(:+)
  end
  return pesos_mesas
end

# tamanos_muestra_discreta([[]], n) => []
# --Dado un nivel de agregados m/c/s y un tamano de muestra n a extrar, calcula cuantos elementos tomar de cada m/c/s para mantener la representatividad de la muestra general. En caso de encontrar cantidades no enteras, las "fracciones de voto" se distribuyen aleatoriamente.
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

# agregar_votos([]) => []
# --Toma un conjunto de votos, y cuenta los totales para cada candidato, estando los candidatos representados por los numeros del 0 al 5.
# --Ej: agregar_votos([1,2,3,1,1,0,5,3]) = [1,3,1,3,0,1]
def agregar_votos(votos)
  votos_agregados = Array.new(6, 0)
  votos.each do |voto|
    votos_agregados[voto] += 1
  end
  return votos_agregados
end

# pesar_muestra([], n) => []
# --Toma una muestra de votos correspondiente a cierta m/c/s, y la pondera por el numero de votantes en ella. Ej: pesar_muestra([1,3,2], 300) = [50,150,100]
def pesar_muestra(muestra, peso)
  return normalizar_una(muestra).map {|votos| votos * peso}
end

# muestra_por_mesa([], n) => []
# --Dada una m/c/s y un tamano muestral n, extrae de la m/c/s una muestra de n votos al azar.
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

# muestral_general([[]], n) => []
# Dado un conjunto de m/c/s y un tamano muestral, crear una muestra con dichas caracteristicas. Involucra primero una llamada a tamano_muestra_discreta() que devuelve los votos a tomar por m/c/s, y luego a muestra_por_mesa(), que toma los votos anteriormente indicados de cada m/c/s.
def muestra_general(mesas, cantidad)
  muestras_por_mesa = []
  
  votos_por_mesa = tamanos_muestra_discreta(mesas, cantidad)
  
  for i in 0..mesas.length-1
    muestras_por_mesa << muestra_por_mesa(mesas[i], votos_por_mesa[i])
  end

  muestra_general = sumar_arrays(muestras_por_mesa)

  return normalizar_una(muestra_general)
end

#############################  
#                           #
#    Extraccion de Datos    #
#                           #
#############################
# Variables auxiliares.
resultado_4dec = [0.379, 0.2162, 0.3221, 0.3446, 0.0564, 0.0228]
votos_por_partido = [68_246, 389_128, 581_096, 621_167, 101_862, 41_194]
resultado_exacto = normalizar_una(votos_por_partido)
=begin
# Creacion de 1000 simulaciones de la noche del escrutinio.
escrutinios = []
i = 1
1_000.times do
  escrutinios << simular_un_escrutinio(votos_mesas)
  p i
  i +=1
end

# 1. Conos de incertidumbre para Carrio y Bergman
# Del array de s simulaciones, tomo unicamente los porcentajes conrrespondientes a 'candidato' y desecho el resto. Obtengo un array de s * n (n = numero de agregados)
# Traspongo el array y obtengo uno donde en cda posicion, estan los s porcentajes que el candidato obtuvo hasta la mesa i.
# Tomo el percentil indicado del array en cada posicion.
# Devuebo un array de n posiciones, cada una con el valor que acumula el percentil indicado por el candidato hasta entonces.
puts "1"

def tomar_valores_candidato(mesas, candidato)
  valores_candidato = []
  mesas.each do |mesa|
    valores_candidato << mesa[candidato]
  end
  return valores_candidato
end

def limites(simulaciones, candidato, posicion)
  valores_candidato = []
  simulaciones.each do |sim|
    valores_candidato << tomar_valores_candidato(sim, candidato)
  end
  porcentajes_parciales = valores_candidato.transpose
  porcentajes_parciales.map {|n| n.sort!}
  resultado = []
  porcentajes_parciales.each do |percs|
    resultado << percs[posicion]
  end
  return resultado
end  

for candidato in (2..3)
  for percentil in [1, 10, 50, 100, 500, 900, 950, 990, 1000]
    curfile = File.open("#{candidato}_#{percentil}.dat", "w")
    limites(escrutinios, candidato, percentil-1).each_with_index do |x, i| 
      curfile.puts "#{i + 1} #{x}"
    end
    curfile.close
  end
end

# 2. Variacion del error absoluto de 200 escrutinios en funcion del numero de mesas computadas.
puts "2"

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

escrutinios.first(200).each_with_index do |escrutinio, index|
  curfile = File.open("escrutinio#{index}.dat", "w")
  deltas = delta_serie(errabs_escrutinio(escrutinio))
  deltas.each_with_index do |delta, i|
    curfile.puts "#{i + 1} #{delta}"
  end
  curfile.close
end

# 3. Frecuencias acumuldas de los valores para los cuales la estabilidad del error absoluto aumenta en un orden de magnitud. En otras palabras, se busca cual es la mesa 'n' a partirde la cual el errror absoluto se estabiliza por debajo de 10/1/0,1/0,01 puntos.
puts "3"

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
=end
# 4. Error absoluto de 10.000 muestras, para tamanos muestrales de 100, 500, 2000 y 10000.
puts "4"

for tamano in [100, 500, 2_000, 10_000]
  curfile = File.open("graf4_#{tamano}.dat", "w")
  errores_muestras = []
  10_000.times do
    errores_muestras  << errabs(muestra_general(votos_circuitos, tamano), resultado_exacto)
  end
  errores_muestras.sort!
  errores_muestras.each_with_index do |errabs, i|
    curfile.puts "#{i + 1} #{errabs}"
  end
  curfile.close
end

# 5. Percentiles comparados para varios tamanos meustrales
puts "5"

enes_grafico_cinco = []
for i in 0..20
  enes_grafico_cinco << (10**(1 + 4.0 / 20 * i)).to_i
end

muestras_grafico_cinco = []

enes_grafico_cinco.each do |ene|
  muestras_ene = []
  10_000.times do
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
