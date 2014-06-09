public interface MEP_ConverterFromXML<T> {
	List<T> convertToDTOFromXML(Dom.Document doc);
}