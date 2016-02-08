dataDir="data/measurements"
plotDir="data/plots"

concatDir="data/concat"
concatFitDir="data/concatFits"

aggrDir="data/aggr"
aggrFitDir="data/aggrFits"

plotsAllDir="all"

# # # # # # # # # # # # # #
# .aggr
# # # # # # # # # # # # # #
#  1: SIZE
#  2: INIT
#  3: ADD_SUCCESS
#  4: ADD_FAILURE
#  5: RANDOM_ELEMENT
#  6: SIZE
#  7: ITERATE
#  8: CONTAINS_SUCCESS
#  9: CONTAINS_FAILURE
# 10: GET_SUCCESS
# 11: GET_FAILURE
# 12: REMOVE_SUCCESS
# 13: REMOVE_FAILURE
# # # # # # # # # # # # # #

# # # # # # # # # # # # # #
# .dat
# # # # # # # # # # # # # #
# 1: size
# 2: avg
# 3: min
# 4: max
# 5: med
# 6: var
# 7: varLow
# 8: varUp
# # # # # # # # # # # # # #

operations=(INIT ADD_SUCCESS ADD_FAILURE RANDOM_ELEMENT SIZE ITERATE CONTAINS_SUCCESS CONTAINS_FAILURE GET_SUCCESS GET_FAILURE REMOVE_SUCCESS REMOVE_FAILURE)

# dataStructures=(DArray DArrayList DHashSet DHashMap DHashTable)
# DArray
# DArrayList
# DHashMap
# DHashSet
# DHashTable

# dataStructures=(DLinkedList DHashArrayList)
# DLinkedList
# DHashArrayList

# dataStructures=(DArrayDeque DHashMultimap DLinkedHashMultimap DEmpty)
# DArrayDeque
# DHashMultimap
# DLinkedHashMultimap
# DEmpty


dataStructures=(DArray DArrayList DHashSet DHashMap DHashTable DLinkedList DHashArrayList)

dataTypes=(Node Edge)