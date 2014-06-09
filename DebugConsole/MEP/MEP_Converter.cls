public interface MEP_Converter<DTOType, sObjectType> {
	
	List<DTOType> convertToDTO(List<sObjectType> objList);
	DTOType convertToDTO(sObjectType obj);
	
}