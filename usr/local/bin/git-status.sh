  echo git diff
  echo - - -
  git diff --stat origin/main 
  echo diff count
  echo - - -
  diff_ct=`git diff --stat origin/main | wc -l`
  echo "Diff count is $diff_ct"
  echo git status
  echo - - -
  git status
