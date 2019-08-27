

export const getLatestTvsShow = async(page) => {
  let curPage = 1;
  if (page) {
      curPage = page;
  }
  
  const apiUrl = `https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=${curPage}`;
  //`https://api.themoviedb.org/4/discover/movie?api_key=6aec6123c85be51886e8f69cd9a3a226&primary_release_year=2019&page=${curPage}&primary_release_year=2019`;
  const result =  await axios.get(apiUrl);
  return result.data.results.map(x => {
   return {
      name: x.name,
      country: x.origin_country,
      overview: x.overview,
      firstAirDate: x.first_air_date,
      voteAverage: x.vote_average
   };
  });

  /*
{"page":1,"total_results":2609,
"total_pages":131,
"results":[{"original_name":"The Boys","genre_ids":[10759,10765],"name":"The Boys",
"popularity":135.403,
"origin_country":["US"],"vote_count":144,
"first_air_date":"2019-07-25",
"backdrop_path":"\/bI37vIHSH7o4IVkq37P8cfxQGMx.jpg",
"original_language":"en",
"id":76479,
"vote_average":8.2,
"overview":"A group of vigilantes known informally as “The Boys” set out to take down corrupt superheroes with no more than blue-collar grit and a willingness to fight dirty.","poster_path":"\/dzOxNbbz1liFzHU1IPvdgUR647b.jpg"},{"original_name":"Pennyworth","genre_ids":[80,18],"name":"Pennyworth","popularity":84.21,"origin_country":["US"],"vote_count":17,"first_air_date":"2019-07-28","backdrop_path":"\/fOdbXYcLTthRYlOA77LkKI9fxu3.jpg","original_language":"en","id":79588,"vote_average":8,"overview":"The origin story of Bruce Wayne's legendary butler, Alfred Pennyworth, a former British SAS soldier who forms a security company and goes to work with Thomas Wayne, Bruce's billionaire father, in 1960s London.",
"poster_path":"\/czVjj5W113Aggz8fmtiW5bY1Vsz.jpg"}
  */

};