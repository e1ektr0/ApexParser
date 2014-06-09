public interface MEP_ConverterDTOtoEntity<sObjectType, DTOType>
{
	sObjectType convertDTOtoEntity(DTOType dto);
	List<sObjectType> convertDTOtoEntity(List<DTOType> listOfDto);
}