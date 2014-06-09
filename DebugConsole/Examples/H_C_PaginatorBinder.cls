//
//This interface sets the interaction protocol between paginator and its client
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (11-09-2013)
public interface H_C_PaginatorBinder
{
	H_C_PaginationParameters getPaginationParameters();
	void setPaginationParameters(H_C_PaginationParameters parameters);
}