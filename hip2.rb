#########################################
#
#     PROCESAMIENTO DE DATOS
#
#########################################


# Guardo cada linea del input en el array 'mesas_raw'

mesas_raw = IO.readlines(Dir.pwd + "/mesas_dip.tsv")

# Elimino la primer linea del archivo, que contiene los titulos de las columnas:
#
#   seccion, circuito, mesa, blancos, AyL, FpV, UNEN, PRO, FIT, CP

mesas_raw.shift()

# Formateo cada mesa para transformarla en un array de numeros enteros y las guardo en mesas_completas.

def emprolijar(array_raw)
  array_prolijo = []
  for line in array_raw
    # quito el \n del final de la linea, la corto sobre los tabs y transformo a enteros el array resultante
    array_prolijo << line.chomp.split("\t").map { |x| x.to_i}
  end
  return array_prolijo
end

mesas_completas = emprolijar(mesas_raw)

# Separo el array con todos los datos en dos:
#     
#     data_mesas, con la info de cada mesa (seccion, circuito, numero de mesa)
#     votos_mesas, con los votos en cada mesa
#
#     data_mesas = [seccion, circuito, mesa]
#     votos_mesas = [blancos, AyL, FpV, UNEN, PRO, FIT, CP] (CP: Camino Popular)


data_mesas = mesas_completas.map(&:dup)
data_mesas.each {|mesa| mesa.pop(7)}

votos_mesas = mesas_completas.map(&:dup)
votos_mesas.each {|mesa| mesa.shift(3)}

# Si se quiere realizar el analisis CON VOTOS EN BLANCO, descomentar la proxima linea:
votos_mesas.each {|mesa| mesa.pop(1)}

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
        puts mesas.length - i + 1
        results << mesas.length - i + 1
        break
      else
      end
    end
  end
  return results
end

#a = simular_limite(1000, votos_mesas, normalizar_una(votos_por_partido))
#p a.sort



#########################
#                       #
#      HIPOTESIS I      #
#                       #
#########################


